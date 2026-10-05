<?php
// TIA OLEO 4 - Motor analitica: tabla de eventos (vincula index.html + panel-control.html)
require_once __DIR__ . '/config.php';
if (session_status() === PHP_SESSION_NONE) session_start();
header('Content-Type: application/json; charset=utf-8');

try {
  $pdo = db();
  $pdo->exec("CREATE TABLE IF NOT EXISTS eventos_analitica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_evento VARCHAR(60) NOT NULL,
    datos_json VARCHAR(1000) NOT NULL DEFAULT '{}',
    pagina VARCHAR(80) NOT NULL DEFAULT '',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tipo (tipo_evento)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");

  $body = json_decode(file_get_contents('php://input'), true);
  $tipo = mb_substr(trim($body['tipo_evento'] ?? ''), 0, 60);
  $datos = $body['datos'] ?? [];
  $pagina = mb_substr(trim($body['pagina'] ?? ''), 0, 80);
  if ($tipo === '') json_out(['ok' => false], 400);

  $datosJson = mb_substr(json_encode($datos, JSON_UNESCAPED_UNICODE) ?: '{}', 0, 1000);
  $stmt = $pdo->prepare('INSERT INTO eventos_analitica (tipo_evento, datos_json, pagina) VALUES (?, ?, ?)');
  $stmt->execute([$tipo, $datosJson, $pagina]);
  json_out(['ok' => true]);
} catch (Throwable $e) {
  json_out(['ok' => false, 'error' => 'Error de BD.'], 500);
}
