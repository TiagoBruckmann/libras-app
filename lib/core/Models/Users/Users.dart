class Users {

  int id;
  String name;
  String mail;
  String password;
  int level;
  String qtyLevel;
  String totalLevel;

  Users({ this.id, this.name, this.mail, this.password, this.level, this.qtyLevel, this.totalLevel });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      mail: json['mail'],
      password: json['password'],
      level: json['level'],
      qtyLevel: json['qty_level'],
      totalLevel: json['total_level'],
    );
  }

  @override
  String toString() => name;
}