<?php

	function replaceFirstPixelAlpha($location){
		$handle = fopen($location, 'rb');
		$img = new Imagick();
		$img->readImageFile($handle);
		fclose($handle);

		$pixelWhite = new ImagickPixel("rgb(255,255,255)");
		$pixelGreen = new ImagickPixel("rgb(32,156,0)");
		$img->paintTransparentImage($pixelWhite, 0.00, 0.00);
		$img->paintTransparentImage($pixelGreen, 0.00, 0.00);
		return $img;
	}

?>