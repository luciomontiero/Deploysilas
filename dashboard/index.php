<?php

declare(strict_types=1);

$root = dirname(__DIR__);
$logsDir = $root . '/logs';
$backupDir = getenv('DEPLOYSILAS_BACKUP_DIR') ?: $root . '/.deploy/backups';
$token = getenv('DEPLOYSILAS_DASHBOARD_TOKEN') ?: '';
$commands = [
    'deploy' => 'Deploy',
    'backup' => 'Backup',
    'rollback' => 'Rollback',
    'update' => 'Atualizar',
    'logs' => 'Logs',
    'migrate' => 'Migrações',
];

function readJson(string $file): array
{
    if (!is_file($file)) {
        return [];
    }

    $data = json_decode((string) file_get_contents($file), true);
    return is_array($data) ? $data : [];
}

function commandOutput(string $root, string $command): string
{
    $allowed = ['deploy', 'backup', 'rollback', 'update', 'migrate'];
    if (!in_array($command, $allowed, true)) {
        return '';
    }

    $binary = escapeshellarg($root . '/scripts/deploysilas');
    $cmd = $binary . ' ' . escapeshellarg($command) . ' 2>&1';
    return (string) shell_exec($cmd);
}

function tailFile(string $file, int $lines = 80): string
{
    if (!is_file($file)) {
        return 'Log indisponivel.';
    }

    $output = shell_exec('tail -n ' . (int) $lines . ' ' . escapeshellarg($file));
    return (string) $output;
}

function listBackups(string $backupDir): array
{
    if (!is_dir($backupDir)) {
        return [];
    }

    $items = array_filter(glob($backupDir . '/*') ?: [], 'is_dir');
    rsort($items);
    return array_slice($items, 0, 10);
}

function diskUsage(string $path): string
{
    $total = @disk_total_space($path) ?: 0;
    $free = @disk_free_space($path) ?: 0;
    if ($total <= 0) {
        return 'Indisponivel';
    }

    $used = $total - $free;
    return sprintf('%.1f%% usado', ($used / $total) * 100);
}

function memoryUsage(): string
{
    $meminfo = @file('/proc/meminfo') ?: [];
    $values = [];
    foreach ($meminfo as $line) {
        if (preg_match('/^(MemTotal|MemAvailable):\s+(\d+)/', $line, $matches)) {
            $values[$matches[1]] = (int) $matches[2];
        }
    }

    if (empty($values['MemTotal']) || empty($values['MemAvailable'])) {
        return 'Indisponivel';
    }

    $used = $values['MemTotal'] - $values['MemAvailable'];
    return sprintf('%.1f%% usado', ($used / $values['MemTotal']) * 100);
}

function cpuLoad(): string
{
    $load = sys_getloadavg();
    return $load ? implode(' / ', array_map(static fn ($value) => number_format((float) $value, 2), $load)) : 'Indisponivel';
}

$actionOutput = '';
$authorized = $token === '' || hash_equals($token, $_POST['token'] ?? '');
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    $actionOutput = $authorized ? commandOutput($root, (string) $_POST['action']) : 'Token invalido.';
}

$version = readJson($root . '/version.json');
$latestLog = tailFile($logsDir . '/deploy.log', 40);
$healthLog = tailFile($logsDir . '/health.log', 40);
$backups = listBackups($backupDir);
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DeploySilas Dashboard</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f5f7f9;
            --panel: #ffffff;
            --text: #172026;
            --muted: #65717b;
            --line: #d8e0e7;
            --accent: #0f766e;
            --danger: #b42318;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        header,
        main {
            max-width: 1180px;
            margin: 0 auto;
            padding: 24px;
        }

        header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--line);
        }

        h1,
        h2 {
            margin: 0;
            letter-spacing: 0;
        }

        h1 {
            font-size: 28px;
        }

        h2 {
            font-size: 18px;
            margin-bottom: 14px;
        }

        .muted {
            color: var(--muted);
            font-size: 14px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 16px;
            margin-bottom: 18px;
        }

        .panel {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 16px;
        }

        .wide {
            grid-column: span 2;
        }

        .full {
            grid-column: 1 / -1;
        }

        .metric {
            font-size: 24px;
            font-weight: 700;
            margin-top: 8px;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        button {
            min-height: 38px;
            border: 1px solid var(--accent);
            border-radius: 6px;
            background: var(--accent);
            color: white;
            font-weight: 700;
            cursor: pointer;
            padding: 0 14px;
        }

        input {
            min-height: 38px;
            border: 1px solid var(--line);
            border-radius: 6px;
            padding: 0 10px;
        }

        pre {
            overflow: auto;
            max-height: 360px;
            padding: 12px;
            border-radius: 6px;
            background: #101820;
            color: #edf5f7;
            font-size: 13px;
            line-height: 1.45;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        td {
            border-top: 1px solid var(--line);
            padding: 10px 0;
            vertical-align: top;
        }

        @media (max-width: 860px) {
            header {
                display: block;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .wide {
                grid-column: auto;
            }
        }
    </style>
</head>
<body>
    <header>
        <div>
            <h1>DeploySilas</h1>
            <div class="muted">Painel administrativo</div>
        </div>
        <div class="muted"><?= htmlspecialchars(date('Y-m-d H:i:s O'), ENT_QUOTES, 'UTF-8') ?></div>
    </header>

    <main>
        <section class="grid">
            <div class="panel">
                <h2>Versao</h2>
                <div class="metric"><?= htmlspecialchars($version['version'] ?? '0.1.0', ENT_QUOTES, 'UTF-8') ?></div>
                <div class="muted"><?= htmlspecialchars($version['commit'] ?? 'Sem commit', ENT_QUOTES, 'UTF-8') ?></div>
            </div>
            <div class="panel">
                <h2>CPU</h2>
                <div class="metric"><?= htmlspecialchars(cpuLoad(), ENT_QUOTES, 'UTF-8') ?></div>
            </div>
            <div class="panel">
                <h2>Memoria</h2>
                <div class="metric"><?= htmlspecialchars(memoryUsage(), ENT_QUOTES, 'UTF-8') ?></div>
            </div>
            <div class="panel">
                <h2>Disco</h2>
                <div class="metric"><?= htmlspecialchars(diskUsage($root), ENT_QUOTES, 'UTF-8') ?></div>
            </div>

            <div class="panel wide">
                <h2>Acoes</h2>
                <form class="actions" method="post">
                    <?php if ($token !== ''): ?>
                        <input type="password" name="token" placeholder="Token">
                    <?php endif; ?>
                    <?php foreach ($commands as $command => $label): ?>
                        <?php if ($command !== 'logs'): ?>
                            <button type="submit" name="action" value="<?= htmlspecialchars($command, ENT_QUOTES, 'UTF-8') ?>">
                                <?= htmlspecialchars($label, ENT_QUOTES, 'UTF-8') ?>
                            </button>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </form>
                <?php if ($actionOutput !== ''): ?>
                    <pre><?= htmlspecialchars($actionOutput, ENT_QUOTES, 'UTF-8') ?></pre>
                <?php endif; ?>
            </div>

            <div class="panel wide">
                <h2>Backups</h2>
                <table>
                    <?php foreach ($backups as $backup): ?>
                        <tr><td><?= htmlspecialchars(basename($backup), ENT_QUOTES, 'UTF-8') ?></td></tr>
                    <?php endforeach; ?>
                    <?php if (!$backups): ?>
                        <tr><td>Nenhum backup encontrado.</td></tr>
                    <?php endif; ?>
                </table>
            </div>

            <div class="panel wide">
                <h2>Deploy Log</h2>
                <pre><?= htmlspecialchars($latestLog, ENT_QUOTES, 'UTF-8') ?></pre>
            </div>
            <div class="panel wide">
                <h2>Health Check</h2>
                <pre><?= htmlspecialchars($healthLog, ENT_QUOTES, 'UTF-8') ?></pre>
            </div>
        </section>
    </main>
</body>
</html>
