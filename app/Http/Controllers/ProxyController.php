<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http; 

class ProxyController extends Controller
{
    public function handle(Request $request, $path = null)
    {
        //$url = $baseUrl . '/' . $path;
        $url = $path;

        $method = $request->method();
        $response = Http::$method($url, $request->all(), $request->except(['_token']));

        // Devolver la respuesta al cliente
        return response($response->body(), $response->status())
            ->header('Content-Type', $response->header('Content-Type'));
    }
}
