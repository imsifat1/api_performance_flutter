class ApiTestCase {
  final String label;
  final String endpoint;

  const ApiTestCase({required this.label, required this.endpoint});
}

const List<ApiTestCase> testCases = [
  ApiTestCase(label: 'Small Product', endpoint: '/products/1'),
  ApiTestCase(label: 'Large Product List', endpoint: '/products'),
  ApiTestCase(label: 'Nested Cart', endpoint: '/carts'),
  ApiTestCase(label: 'Users List', endpoint: '/users'),
  ApiTestCase(label: 'Invalid Endpoint', endpoint: '/invalid-endpoint'),
];
