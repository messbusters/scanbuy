<?php
require __DIR__ . '/../vendor/autoload.php';

use Google\Cloud\Core\Exception\ServiceException;
use Google\Cloud\Translate\TranslateClient;

if (!isset($argv[1])) {
    echo json_encode([
        'success' => false,
        'message' => 'Empty text to translate!',
    ]);
    exit;
}

$text = trim($argv[1]);

if (strlen($text) < 2) {
    echo json_encode([
        'success' => false,
        'message' => 'Text to translate should have more than two characters!',
    ]);
    exit;
}

$translate = new TranslateClient();

try {
    $result = $translate->translate($text, [
        'source' => 'en',
        'target' => 'ro',
        'format' => 'text',
        'model'  => 'base',
    ]);
} catch (ServiceException  $exception) {
    $message = json_decode($exception->getMessage());
    echo json_encode([
        'success' => false,
        'message' => $message->error->message
    ]);
    exit;
}

echo json_encode([
    'success' => true,
    'from' => $text,
    'to' => $result['text']
], JSON_UNESCAPED_UNICODE);