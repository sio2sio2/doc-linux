<?php
/*
Plugin Name: MisFunciones
Plugin URI: http://docs.iescdl.es/~josem/LI/index.html
Description: Funciones para las que no merece la pena un plugin.
Author: José Miguel Sánchez Alés
Version: 0.1
Author URI: http://docs.iescdl.es/~josem/LI/index.html
License: GPL2
*/

// Tomado de http://ecolosites.eelv.fr/how-to-finally-allow-iframes-in-wordpress-or-any-other-tag/
add_filter('wp_kses_allowed_html', 'esw_author_cap_filter', 1, 1);

function esw_author_cap_filter($allowedposttags) {
   //Here put your conditions, depending your context
   if (!current_user_can( 'publish_posts'))
      return $allowedposttags;

   // Here add tags and attributes you want to allow
   $allowedposttags['iframe']=array(
      'width' => array(),
      'height' => array(),
      'frameborder' => array(),
      'src' => array(),
   );

   return $allowedposttags;
}

add_filter('http_request_host_is_external', 'my_http_request_host_is_external');

function my_http_request_host_is_external() {
    return true;
}

