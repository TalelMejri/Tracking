<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function RegitserUser(Request $request)
    {
        $user = User::create([
            "name" => $request->name,
            "email" => $request->email,
            "password" => bcrypt($request->password)
        ]);
        return response()->json(['data' => "user created"], 200);
    }

    public function AuthUser(Request $request)
    {
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $authUser = Auth::user();

            $token = $authUser->createToken("api_token")->plainTextToken;

            $response = [
                'user' => $authUser,
                'token' => $token
            ];

            return response()->json($response, 201);
        }else{
            return response()->json(["message"=>"User Not Found"], 404);

        }
    }
}
