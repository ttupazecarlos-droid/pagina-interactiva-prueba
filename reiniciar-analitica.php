<?php
// TIA OLEO 4 - Reiniciar analitica (boton del panel)
require_once __DIR__ . '/config.php';
header('Content-Type: application/json; charset=utf-8');
try {
  db()->exec("CREATE TABLE IF NOT EXISTS eventos_analitica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_evento VARCHAR(60) NOT NULL,
    datos_json VARCHAR(1000) NOT NULL DEFAULT '{}',
    pagina VARCHAR(80) NOT NULL DEFAULT '',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
  db()->exec('DELETE FROM eventos_analitica');
  json_out(['ok' => true]);
} catch (Throwable $e) {
  json_out(['ok' => false], 500);
}
