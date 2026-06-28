import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ModelCapability {
  @JsonValue('tools') tools,
  @JsonValue('parallel_tools') parallelTools,
  @JsonValue('structured_output') structuredOutput,
  @JsonValue('json') json,
  @JsonValue('stream') stream,
  @JsonValue('vision') vision,
  @JsonValue('image_generation') imageGeneration,
  @JsonValue('audio_input') audioInput,
  @JsonValue('audio_output') audioOutput,
  @JsonValue('embeddings') embeddings,
  @JsonValue('reasoning') reasoning,
  @JsonValue('system_prompt') systemPrompt,
  @JsonValue('web_search') webSearch,
  @JsonValue('file_upload') fileUpload,
  @JsonValue('pdf') pdf,
  @JsonValue('function_call') functionCall,
  @JsonValue('seed') seed,
  @JsonValue('response_format') responseFormat,
  @JsonValue('cache') cache,
  @JsonValue('citations') citations,
  @JsonValue('multimodal') multimodal,
}
