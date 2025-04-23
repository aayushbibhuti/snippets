<?php
$string = 'example.com';

if (preg_match('/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/', $string)) {
  echo "The string '$string' is in website format.";
} else {
  echo "The string '$string' is not in website format.";
}
?>
