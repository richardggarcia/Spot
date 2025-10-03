/// Port (Interface) para servicios de análisis LLM/Noticias
/// Permite intercambiar proveedores de LLM (OpenAI, Anthropic, local, etc.)
/// sin afectar la lógica de dominio
abstract class LlmAnalysisPort {
  /// Genera veredicto rápido para una criptomoneda
  /// [symbol] Símbolo de la crypto (ej: 'BTC')
  /// [deepDrop] Porcentaje de caída profunda
  /// [rebound] Porcentaje de rebote
  /// Retorna análisis conciso de 5-7 palabras
  /// Ejemplo: "Caída por profit taking"
  Future<String> generateVerdict({
    required String symbol,
    required double deepDrop,
    required double rebound,
  });

  /// Verifica si el servicio LLM está disponible
  Future<bool> isAvailable();
}
