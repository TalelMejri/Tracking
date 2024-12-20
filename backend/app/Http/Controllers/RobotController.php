<?php

namespace App\Http\Controllers;

use App\Models\Robot;
use Illuminate\Http\Request;

class RobotController extends Controller
{
    function getRobots($id)
    {
        $robots = Robot::where("user_id", "=", $id)->get();
        return response()->json([
            'data' => $robots
        ], 200);
    }

    function getRobotById($id)
    {
        $robot = Robot::find($id);
        if ($robot) {
            return response()->json(['data' => $robot], 200);
        } else {
            return response()->json(['data' => "Not Found "], 404);
        }
    }

    function UpdateRobot(Request $request, $id)
    {
        $robot = Robot::find($id);
        if ($robot) {
            $robot->latitude = $request->latitude;
            $robot->longitude = $request->longitude;
            $robot->save();
            return response()->json(['data' => "Update Success"], 201);
        } else {
            return response()->json(['data' => "Not Found"], 404);
        }
    }

    function DeleteRobot($id)
    {
        $robot = Robot::find($id);
        if ($robot) {
            $robot->delete();
            return response()->json(['Message' => "robot Deleted"], 200);
        } else {
            return response()->json(["Message" => "Not Found"], 404);
        }
    }

    function UpdateEtat($id)
    {
        $robot = Robot::find($id);
        if ($robot) {
            $robot->etat = !$robot->etat;
            $robot->save();
            return response()->json(['Message' => "robot Updated "], 200);
        } else {
            return response()->json(["Message" => "Not Found"], 404);
        }
    }

    function AddRobot(Request $request)
    {
        $robot = Robot::find($request->id);
        if ($robot) {
            return response()->json(["message" => "already exists"], 200);
        } else {
            Robot::create([
                "id" => $request->id,
                "name" => $request->name,
                "latitude" => $request->latitude,
                "longitude" => $request->longitude,
                "user_id" => $request->user_id,
                "battery" => $request->battery,
                "niveau_poubelle" => $request->niveau,
                "etat" => 0,
            ]);
            return response()->json(["message" => "Added"], 201);
        }
    }
}
