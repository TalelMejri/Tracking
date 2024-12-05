class User{
  int id;
  String Nom;
  String Email;



  User({
    required this.id,
    required this.Nom,
    required this.Email,
  });

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id: json['id'],
      Nom: json['name'],
      Email: json['email'],
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'id':id,
      'name': Nom,
      'email': Email    };
  }

   @override
  String toString() {
    return 'User{id: $id, Nom: $Nom, Email: $Email}';
  }
 
}