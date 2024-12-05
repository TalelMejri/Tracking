import 'package:flutter/material.dart';
import 'package:track_test/model/BikeModel.dart';
import 'package:track_test/pages/TrackBikes.dart';
import 'package:track_test/services/BikeServices.dart';

class LisetBikes extends StatefulWidget {
  const LisetBikes({super.key});

  @override
  State<LisetBikes> createState() => _LisetBikesState();
}

class _LisetBikesState extends State<LisetBikes> {
  List<BikeModel> bikes = [];

  var loading_reserved = false;
  var loading = true;
  final BikeSrvice _bikeService = BikeSrvice();

  fetchBikes() async {
    List<BikeModel> bikes_data = await _bikeService.getBikes();
    setState(() {
      bikes = bikes_data;
      loading = false;
    });
  }

  UpdateReserved(BikeModel _bikemodel) async {
    setState(() {
      loading_reserved = true;
    });
    await _bikeService.UpdateBikeReserved(_bikemodel.id);
    setState(() {
      loading_reserved = false;
    });
    fetchBikes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bikemodel.reserved == 1 ? "Bike Not Reserved" : "Bike Reserved",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bikemodel.reserved == 1 ? Colors.red : Colors.green,
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
  }

  @override
  void initState() {
    super.initState();
    fetchBikes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1, left: 1, right: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : bikes.isEmpty
              ? const Center(
                  child: Text("No bikes Yet",
                      style: TextStyle(color: Colors.white, fontSize: 20)))
              : ListView.builder(
                  itemCount: bikes.length,
                  itemBuilder: (context, index) {
                    BikeModel _BikeModel = bikes[index];
                    return Dismissible(
                      key: Key(_BikeModel.id.toString()),
                      background: Container(
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text(
                                  "Would you like to delete Bike ${_BikeModel.name}?"),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  child: const Text("Close",
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        await _bikeService.DeleteBike(_BikeModel.id);
                        setState(() {
                          bikes.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              " Bike Deleted With Sucess",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.green,
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
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Transform.scale(
                              scale: 1.2,
                              child: Text(_BikeModel.id.toString())),
                          title: Text(
                            "${_BikeModel.name}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "Nombre Location " +
                                _BikeModel.NbrLocation.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              loading_reserved
                                  ? const CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 1,
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        UpdateReserved(_BikeModel);
                                      },
                                      icon: Icon(
                                        _BikeModel.reserved == 1
                                            ? Icons.lock
                                            : Icons.lock_open,
                                        color: _BikeModel.reserved == 1
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrackBike(bike: _BikeModel)));
                                },
                                icon: const Icon(
                                  Icons.info,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
