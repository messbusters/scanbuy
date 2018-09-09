<?php

namespace Google\Cloud\Samples\Vision;

require __DIR__ . '/../vendor/autoload.php';

use Google\Cloud\Vision\V1\ImageAnnotatorClient;

if (!isset($argv[1])) {
    echo json_encode([
        'success' => false,
        'message' => 'Empty image path!',
    ]);
    exit;
}

$path = trim($argv[1]);
try {
    $image = file_get_contents($path);
} catch (\Exception $exception) {
    echo json_encode([
        'success' => false,
        'message' => $exception->getMessage(),
        'source' => $path
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
if (!$image) {
    echo json_encode([
        'success' => false,
        'message' => 'Image could not be loaded!',
        'source' => $path
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $imageAnnotator = new ImageAnnotatorClient();
} catch (\Exception $exception) {
    echo json_encode([
        'success' => false,
        'message' => $exception->getMessage(),
    ]);
    exit;
}

$labelsResponse = [];
$response = $imageAnnotator->labelDetection($image);
$labels = $response->getLabelAnnotations();
if ($labels) {
    foreach ($labels as $label) {
        $labelsResponse[] = [
            'description' => $label->getDescription(),
            'score' => $label->getScore()
        ];
    }
}

$logosResponse = [];
$response = $imageAnnotator->logoDetection($image);
$logos = $response->getLogoAnnotations();
if ($logos) {
    foreach ($logos as $logo) {
        $logosResponse[] = [
            'description' => $logo->getDescription(),
            'score' => $logo->getScore()
        ];
    }
}

$textBlocks = [];
$response = $imageAnnotator->documentTextDetection($image);
$annotation = $response->getFullTextAnnotation();
if ($annotation) {
    foreach ($annotation->getPages() as $page) {
        foreach ($page->getBlocks() as $block) {
            $block_text = '';
            foreach ($block->getParagraphs() as $paragraph) {
                foreach ($paragraph->getWords() as $word) {
                    foreach ($word->getSymbols() as $symbol) {
                        $block_text .= $symbol->getText();
                    }
                    $block_text .= ' ';
                }
            }
            $textBlocks[] = [
                'content' => $block_text,
                'confidence' => $block->getConfidence()
            ];
        }
    }
}

$colorsResponse = [];
$response = $imageAnnotator->imagePropertiesDetection($image);
$props = $response->getImagePropertiesAnnotation();
if ($props) {
    foreach ($props->getDominantColors()->getColors() as $colorInfo) {
        $color = $colorInfo->getColor();
        $colorsResponse[] = [
            'fraction' => $colorInfo->getPixelFraction(),
            'red' => $color->getRed(),
            'green' => $color->getGreen(),
            'blue' => $color->getBlue()
        ];
    }
}

$imageAnnotator->close();

echo json_encode([
    'success' => true,
    'source' => $path,
    'labels' => $labelsResponse,
    'logos' => $logosResponse,
    'text_blocks' => $textBlocks,
    'colors' => $colorsResponse
], JSON_UNESCAPED_UNICODE);