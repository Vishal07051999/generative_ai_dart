/// This class represents a content blob with a specific MIME type and data.
/// Each blob is characterized by its MIME type (like `"text/plain"`,
/// `"image/png"`, etc.) and the actual content in the form of a string.
/// This class has a factory constructor [GenerativeContentBlob.fromJson] that
/// constructs a `GenerativeContentBlob` object from a JSON object. It also has
/// a method [toJson] that converts a [GenerativeContentBlob] object into a JSON object.
class GenerativeContentBlob {
  /// A final string representing the MIME type of the blob
  final String mimeType;

  /// A final string representing the actual content of the blob
  final String data;

  /// Constructs a new [GenerativeContentBlob] object with MIME type and data
  GenerativeContentBlob({required this.mimeType, required this.data});

  /// Factory method that returns a [GenerativeContentBlob] object from a JSON object.
  /// The JSON object must have `"mimeType"` and `"data"` keys.
  factory GenerativeContentBlob.fromJson(Map<String, dynamic> json) =>
      GenerativeContentBlob(mimeType: json["mimeType"], data: json["data"]);

  /// Converts an instance of [GenerativeContentBlob] into a JSON object.
  Map<String, dynamic> toJson() => {'mimeType': mimeType, 'data': data};
}

/// An abstract base class named [Part].
///
/// [Part] is a base class for other classes, containing common properties
/// like [text] and [inlineData] and methods like [Part.fromJson] and
/// [Part.toJson].
abstract class Part {
  /// An optional string that describes the part
  final String? text;

  /// An optional instance of [GenerativeContentBlob] that may be inline with part
  final GenerativeContentBlob? inlineData;

  /// A private constructor used internally in the class.
  Part._({this.text, this.inlineData});

  /// Factory method for creating instances of [Part] from a JSON object.
  ///
  /// This method creates a variant of [Part] (`TextPart` or `InlineDataPart`)
  /// based on the provided [json] object. If both `text` and `inlineData`
  /// fields in the JSON are `null`, this method throws an `AssertionError`.
  factory Part.fromJson(Map<String, dynamic> json) {
    if (json["text"] != null) {
      return TextPart(json["text"]);
    }
    if (json["inlineData"] != null) {
      return InlineDataPart(GenerativeContentBlob.fromJson(json["inlineData"]));
    }
    throw AssertionError("Both Text and Inline Data can't be null");
  }

  /// A method to serialize a [Part] object to a JSON object.
  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (inlineData != null) 'inlineData': inlineData
      };
}

/// This final class [TextPart] extends from the [Part] class. It represents a section of
/// text, with the text being derived from the super class.
class TextPart extends Part {
  /// A getter to get the [text] from the base class, assumed not null
  @override
  String get text => super.text!;

  /// Constructor for [TextPart] that takes a string as an input and calls the
  /// internal constructor from the base class with the input text
  TextPart(String text) : super._(text: text);
}

/// This final class [InlineDataPart] extends from the [Part] class. It represents an inline
/// data part, with the inline data being derived from the super class.
class InlineDataPart extends Part {
  /// A getter to get the [inlineData] from the base class, assumed not null
  @override
  GenerativeContentBlob get inlineData => super.inlineData!;

  /// Constructor for [InlineDataPart] that takes a [GenerativeContentBlob] as
  /// an input and calls the internal constructor from the base class with the input
  /// inline data.
  InlineDataPart(GenerativeContentBlob inlineData)
      : super._(inlineData: inlineData);
}

/// This final class [Content] represents a list of [Part] instances.
///
/// This class provides a constructor to create a [Content] object with a list
/// of [Part], a role, and factory methods [Content.user] and [Content.model] to
/// create an instance of [Content].
class Content {
  final List<Part> parts;
  final String? role;

  /// Construct a [Content] object;
  Content({required this.parts, required this.role});

  /// Factory method to create a [Content] object from a JSON object that
  /// contains a 'parts' field, where each part is constructed using
  /// the [Part.fromJson] method.
  ///
  /// If 'parts' field is of type [String], then covert it to [TextPart]
  /// and, add it to [parts]
  factory Content.fromJson(Map<String, dynamic> json) {
    final partsJson = json["parts"];

    final parts = <Part>[];

    if (partsJson is String) {
      parts.add(TextPart(partsJson));
    } else {
      partsJson?.forEach((partJson) {
        parts.add(Part.fromJson(partJson));
      });
    }

    return Content(parts: parts, role: json["role"] as String?);
  }

  /// Factory method to create a user [Content] object.
  Content.user({required this.parts}) : role = "user";

  /// Factory method to create a model [Content] object.
  Content.model({required this.parts}) : role = "model";

  /// Converts the current [Content] object into a JSON object.
  Map<String, dynamic> toJson() => {
        "parts": parts.map((e) => e.toJson()).toList(),
        if (role != null) "role": role
      };
}
