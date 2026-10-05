<?php
// ============================================================
// TIA OLEO 4 - Conexion a MySQL (XAMPP)
// Usa PDO + consultas preparadas (anti inyeccion SQL).
// ============================================================

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'tia_oleo4');
define('DB_USER', 'root');
define('DB_PASS', '');          // XAMPP por defecto: sin contraseña
define('DB_CHARSET', 'utf8mb4');

function db(): PDO {
  static $pdo = null;
  if ($pdo instanceof PDO) return $pdo;

  $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;
  $opts = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
  ];
  $pdo = new PDO($dsn, DB_USER, DB_PASS, $opts);
  return $pdo;
}

function json_out($data, int $code = 200): void {
  http_response_code($code);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode($data, JSON_UNESCAPED_UNICODE);
  exit;
}
