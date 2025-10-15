/// Modelo para el registro de dispositivo en el backend
class DeviceRegistration {
  final String fcmToken;
  final String platform;
  final List<String> cryptos;
  final double minDropPercent;
  final NotificationPreferences? preferences;

  const DeviceRegistration({
    required this.fcmToken,
    required this.platform,
    required this.cryptos,
    this.minDropPercent = 3.0,
    this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcmToken': fcmToken,
      'platform': platform,
      'cryptos': cryptos,
      'minDropPercent': minDropPercent,
      if (preferences != null) 'preferences': preferences!.toJson(),
    };
  }

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
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
  }
}

/// Preferencias de notificaciones
class NotificationPreferences {
  final QuietHours? quietHours;
  final int? maxAlertsPerDay;

  const NotificationPreferences({
    this.quietHours,
    this.maxAlertsPerDay,
  });

  Map<String, dynamic> toJson() {
    return {
      if (quietHours != null) 'quietHours': quietHours!.toJson(),
      if (maxAlertsPerDay != null) 'maxAlertsPerDay': maxAlertsPerDay,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      quietHours: json['quietHours'] != null
          ? QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>)
          : null,
      maxAlertsPerDay: json['maxAlertsPerDay'] as int?,
    );
  }
}

/// Horario silencioso
class QuietHours {
  final String start; // Formato: "22:00"
  final String end; // Formato: "08:00"

  const QuietHours({
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }
}

/// Respuesta del backend al registrar dispositivo
class DeviceRegistrationResponse {
  final bool success;
  final String? tokenId;
  final String message;

  const DeviceRegistrationResponse({
    required this.success,
    this.tokenId,
    required this.message,
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return DeviceRegistrationResponse(
      success: json['success'] as bool,
      tokenId: json['tokenId'] as String?,
      message: json['message'] as String,
    );
  }
}
