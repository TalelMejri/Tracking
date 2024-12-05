import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:track_test/services/BikeServices.dart';

class AddBike extends StatefulWidget {
  const AddBike({
    super.key,
  });

  @override
  State<AddBike> createState() => _AddBikeState();
}

class _AddBikeState extends State<AddBike> {
  final _formKey = GlobalKey<FormState>();

  String id = "";
  String name = "";
  double lat = 0.0;
  LocationData? currentLocation;
  double long = 0.0;
  bool loading = false;

  late BikeSrvice _bikeSrvice = BikeSrvice();

  Future<void> _getCurrentLocation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        long = userLocation.longitude!;
        lat = userLocation.latitude!;
      });
    } on Exception {
      currentLocation = null;
    }
    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
        long = newLocation.longitude!;
        lat = newLocation.latitude!;
      });
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await _getCurrentLocation();
      setState(() {
        loading = true;
      });
      bool correctAnswer = await _bikeSrvice.AddBike(id, name, lat, long);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            correctAnswer ? "Bike Added With Success" : "Id Bike Already Exist",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: !correctAnswer ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: "Close",
            textColor: Colors.yellow,
            onPressed: () {
              print("Undo action clicked!");
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Bike",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        shadowColor: Colors.blueAccent.withOpacity(0.5),
        elevation: 8,
        backgroundColor: const Color(0xFF50586C),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFDCE2F0)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Card(
                      margin: const EdgeInsets.only(top: 80),
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.electric_bike,
                                size: 50,
                              ),
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return " Id Required";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(() {
                                    id = val;
                                  });
                                },
                                initialValue: id.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Id Bike",
                                  hintText: "Enter Id Bike",
                                  prefixIcon: Icon(Icons.numbers),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.blue)),
                                  errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.red)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return " Name Required";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(() {
                                    name = val;
                                  });
                                },
                                initialValue: name,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    labelText: "Name Bike",
                                    hintText: "Enter Name Bike",
                                    errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3, color: Colors.red)),
                                    prefixIcon: Icon(Icons.account_box)),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      Colors.blue, // Button color (primary)
                                  onPrimary: Colors.white, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  elevation: 5, // Shadow effect
                                ),
                                onPressed: loading
                                    ? null // Disable button if loading
                                    : () {
                                        _submit(); // Call your submit method
                                      },
                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Save",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                              )
                            ],
                          ))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
