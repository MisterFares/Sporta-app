class ImageUrlHelper {
  static const String baseUrl = 'https://sporta.runasp.net';
  static const String fallbackIpfsGateway = 'https://ipfs.io';
  
  static String? getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    String processedPath = imagePath;
    
    // Replace cloudflare-ipfs.com with working gateway for ALL images
    if (processedPath.contains('cloudflare-ipfs.com')) {
      processedPath = processedPath.replaceAll(
        'https://cloudflare-ipfs.com',
        fallbackIpfsGateway,
      );
      print('🔄 Replaced IPFS gateway: $processedPath');
    }
    
    // If it's already a full URL (http/https), return as is
    if (processedPath.startsWith('http://') ||
        processedPath.startsWith('https://')) {
      print('🌐 External URL: $processedPath');
      return processedPath;
    }
    
    // Local file paths
    if (processedPath.startsWith('/storage/') ||
        processedPath.startsWith('file://') ||
        processedPath.startsWith('/data/')) {
      return processedPath;
    }
    
    // Relative path - convert to full URL
    final cleanPath = processedPath.startsWith('/') 
        ? processedPath.substring(1) 
        : processedPath;
    
    final fullUrl = '$baseUrl/$cleanPath';
    print('🔄 Converted to full URL: $fullUrl');
    return fullUrl;
  }
}