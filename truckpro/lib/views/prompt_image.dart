class PromptImage {
  final String path;
  final int promptIndex;

  PromptImage(this.path, this.promptIndex);

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'promptIndex': promptIndex,
    };
  }
  
}