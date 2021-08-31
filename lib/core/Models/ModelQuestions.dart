class ModelQuestions {

  int id;
  String awnser;

  ModelQuestions( this.id, this.awnser );

  ModelQuestions.complete( int id, String awnser ) {
    this.id = id;
    this.awnser = awnser;
  }

  factory ModelQuestions.fromJson( Map<String, dynamic> json ) {
    return ModelQuestions (
      json["id"],
      json["awnser"]
    );
  }

  @override
  String toString() => awnser;
}