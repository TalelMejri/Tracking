<?php

namespace App\Http\Controllers;

use App\Models\Bike;
use Illuminate\Http\Request;

class BikeController extends Controller
{
    function getBikes($id)
    {
        $bikes = Bike::where("user_id","=",$id)->get();
        $bikesReserved = Bike::where("reserved", "=", true)->count();
        $bikesNotReserved = Bike::where("reserved", "=", false)->count();
        return response()->json([
            'data' => $bikes,
            'bikesReserved' => $bikesReserved,
            'bikesNotReserved' => $bikesNotReserved
        ], 200);
    }

    function GetBikesByNbrLocation($id)
    {
        $bikes = Bike::orderByDesc("NbrLocation")->where("user_id","=",$id)->get();
        return response()->json(['data' => $bikes], 200);
    }
    function getBikeById($id)
    {
        $bicycle = Bike::find($id);
        if ($bicycle) {
            return response()->json(['data' => $bicycle], 200);
        } else {
            return response()->json(['data' => "Not Found "], 404);
        }
    }

    function UpdateBikes(Request $request, $id)
    {
        $bus = Bike::find($id);
        if ($bus) {
            $bus->latitude = $request->latitude;
            $bus->longitude = $request->longitude;
            $bus->save();
            return response()->json(['data' => "Update Success"], 201);
        } else {
            return response()->json(['data' => "Not Found"], 404);
        }
    }

    function DeleteBike($id)
    {
        $bike = Bike::find($id);
        if ($bike) {
            $bike->delete();
            return response()->json(['Message' => "Bike Deleted"], 200);
        } else {
            return response()->json(["Message" => "Not Found"], 404);
        }
    }

    function UpdateReserved($id)
    {
        $bike = Bike::find($id);
        if ($bike) {
            $bike->reserved = !$bike->reserved;
            $bike->NbrLocation = $bike->NbrLocation + 1;
            $bike->save();
            return response()->json(['Message' => "Bike Updated Reserved"], 200);
        } else {
            return response()->json(["Message" => "Not Found"], 404);
        }
    }

    function AddBike(Request $request)
    {
        $bike = Bike::find($request->id);
        if ($bike) {
            return response()->json(["message" => "already exists"], 200);
        } else {
            Bike::create([
                "id" => $request->id,
                "name" => $request->name,
                "latitude" => $request->latitude,
                "longitude" => $request->longitude,
                "user_id"=>$request->user_id
            ]);
            return response()->json(["message" => "Added"], 201);
        }
    }
}
