class Users {

  int id;
  String name;
  String mail;
  String password;

  Users({ this.id, this.name, this.mail, this.password });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      mail: json['mail'],
      password: json['password'],
    );
  }

  @override
  String toString() => name;
}