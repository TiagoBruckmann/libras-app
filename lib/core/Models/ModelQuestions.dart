class ModelQuestions {

  int id;
  String awnser;
  String banner;

  ModelQuestions( this.id, this.awnser, this.banner );

  ModelQuestions.complete( int id, String awnser, String banner ) {
    this.id = id;
    this.awnser = awnser;
    this.banner = banner;
  }

  factory ModelQuestions.fromJson( Map<String, dynamic> json ) {
    return ModelQuestions (
      json["id"],
      json["awnser"],
      json["banner"]
    );
  }

  @override
  String toString() => awnser;
}