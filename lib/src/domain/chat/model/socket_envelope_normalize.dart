/// Normalizes top-level fields on inbound WebSocket envelopes.
Map<String, dynamic> normalizeSocketEnvelopeJson(Map<String, dynamic> json) {
  final m = Map<String, dynamic>.from(json);
  if (m['sessionId'] == null && m['SessionId'] != null) {
    m['sessionId'] = m['SessionId'];
  }
  return m;
}
