/// Jugador que viene dentro de `TokenResponse`.
class SessionPlayer {
  const SessionPlayer({
    required this.id,
    required this.username,
    required this.email,
  });

  final String id;
  final String username;
  final String email;

  factory SessionPlayer.fromJson(Map<String, dynamic> json) => SessionPlayer(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
  );
}

/// Respuesta de `/auth/register`, `/auth/login` y `/auth/refresh`.
class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.expiresInSec,
    required this.player,
    this.refreshToken,
  });

  final String accessToken;
  final int expiresInSec;
  final String? refreshToken;
  final SessionPlayer player;

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
    accessToken: json['accessToken'] as String,
    expiresInSec: (json['expiresInSec'] as num).toInt(),
    refreshToken: json['refreshToken'] as String?,
    player: SessionPlayer.fromJson(json['player'] as Map<String, dynamic>),
  );
}
