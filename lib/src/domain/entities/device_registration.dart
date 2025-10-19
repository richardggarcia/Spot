/// Modelo para el registro de dispositivo en el backend
class DeviceRegistration {

  const DeviceRegistration({
    required this.fcmToken,
    required this.platform,
    required this.cryptos,
    this.minDropPercent = 3.0,
    this.preferences,
  });

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) => DeviceRegistration(
      fcmToken: json['fcmToken'] as String,
      platform: json['platform'] as String,
      cryptos: (json['cryptos'] as List<dynamic>).cast<String>(),
      minDropPercent: (json['minDropPercent'] as num?)?.toDouble() ?? 3.0,
      preferences: json['preferences'] != null
          ? NotificationPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            )
          : null,
    );
  final String fcmToken;
  final String platform;
  final List<String> cryptos;
  final double minDropPercent;
  final NotificationPreferences? preferences;

  Map<String, dynamic> toJson() => {
      'fcmToken': fcmToken,
      'platform': platform,
      'cryptos': cryptos,
      'minDropPercent': minDropPercent,
      if (preferences != null) 'preferences': preferences!.toJson(),
    };
}

/// Preferencias de notificaciones
class NotificationPreferences {

  const NotificationPreferences({
    this.quietHours,
    this.maxAlertsPerDay,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => NotificationPreferences(
      quietHours: json['quietHours'] != null
          ? QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>)
          : null,
      maxAlertsPerDay: json['maxAlertsPerDay'] as int?,
    );
  final QuietHours? quietHours;
  final int? maxAlertsPerDay;

  Map<String, dynamic> toJson() => {
      if (quietHours != null) 'quietHours': quietHours!.toJson(),
      if (maxAlertsPerDay != null) 'maxAlertsPerDay': maxAlertsPerDay,
    };
}

/// Horario silencioso
class QuietHours { // Formato: "08:00"

  const QuietHours({
    required this.start,
    required this.end,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) => QuietHours(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  final String start; // Formato: "22:00"
  final String end;

  Map<String, dynamic> toJson() => {
      'start': start,
      'end': end,
    };
}

/// Respuesta del backend al registrar dispositivo
class DeviceRegistrationResponse {

  const DeviceRegistrationResponse({
    required this.success,
    this.tokenId,
    required this.message,
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) => DeviceRegistrationResponse(
      success: json['success'] as bool,
      tokenId: json['tokenId'] as String?,
      message: json['message'] as String,
    );
  final bool success;
  final String? tokenId;
  final String message;
}
