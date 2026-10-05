<?php
// POST /api/logout.php -> cierra la sesion del admin
require_once __DIR__ . '/../config.php';
if (session_status() === PHP_SESSION_NONE) session_start();
header('Content-Type: application/json; charset=utf-8');

$_SESSION = [];
if (ini_get('session.use_cookies')) {
  $p = session_get_cookie_params();
  setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
}
session_destroy();
json_out(['ok' => true]);
