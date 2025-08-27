// Reference points ordered by rough geographic position
const REFERENCE_POINTS = [
  // Central points
  {
    game: { x: 0.0, y: 0.0 },
    map: { lng: -97.383049, lat: 11.992 },
  },
  {
    game: { x: -52.34, y: -254.46 },
    map: { lng: -98.2266, lat: 6.9408 },
  },
  {
    game: { x: -510.44, y: -371.56 },
    map: { lng: -107.4021, lat: 4.7763 },
  },
  // Southern point
  {
    game: { x: 192.18, y: -3009.55 },
    map: { lng: -93.3233, lat: -43.323 },
  },
  {
    game: { x:-966.44, y: -3162.13 },
    map: { lng: -116.49922, lat: -45.5551 }
  },
  {
    game: { x: 222.51715087890625, y: -3328.126220703125 },
    map: { lng: -92.79132004220685, lat: -47.80717334396935 }
  },
  // Eastern point
  {
    game: { x: 1916.57, y: -959.06 },
    map: { lng: -59.047, lat: -7.2755 },
  },
  // Northern points (ordered south to north)
  {
    game: { x: -2582.43, y: 2286.39 },
    map: { lng: -148.6607, lat: 49.9221 },
  },
  {
    game: { x: -2256.86, y: 4326.72 },
    map: { lng: -142.3285, lat: 69.7424 },
  },
  // Extreme northern point
  {
    game: { x: 91.8, y: 7028.52 },
    map: { lng: -95.3158, lat: 82.0328 },
  },
];
// Reference points ordered by rough geographic position

// Polynomial regression for longitude (x -> lng)
const calculateLongitudeTransform = () => {
  // Using quadratic regression: lng = a * x² + b * x + c
  const sumX = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.x, 0);
  const sumX2 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.x ** 2, 0);
  const sumX3 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.x ** 3, 0);
  const sumX4 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.x ** 4, 0);
  const sumY = REFERENCE_POINTS.reduce((acc, p) => acc + p.map.lng, 0);
  const sumXY = REFERENCE_POINTS.reduce(
    (acc, p) => acc + p.game.x * p.map.lng,
    0
  );
  const sumX2Y = REFERENCE_POINTS.reduce(
    (acc, p) => acc + p.game.x ** 2 * p.map.lng,
    0
  );

  const n = REFERENCE_POINTS.length;
  const matrix = [
    [n, sumX, sumX2],
    [sumX, sumX2, sumX3],
    [sumX2, sumX3, sumX4],
  ];
  const constants = [sumY, sumXY, sumX2Y];

  // Solve for coefficients (a, b, c)
  const [c, b, a] = solveLinearSystem(matrix, constants);
  return { a, b, c };
};

// Polynomial regression for latitude (y -> lat)
const calculateLatitudeTransform = () => {
    // Quartic regression: lat = a * y⁴ + b * y³ + c * y² + d * y + e
    const sumY = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y, 0);
    const sumY2 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 2, 0);
    const sumY3 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 3, 0);
    const sumY4 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 4, 0);
    const sumY5 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 5, 0);
    const sumY6 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 6, 0);
    const sumY7 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 7, 0);
    const sumY8 = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y ** 8, 0);
    const sumZ = REFERENCE_POINTS.reduce((acc, p) => acc + p.map.lat, 0);
    const sumYZ = REFERENCE_POINTS.reduce((acc, p) => acc + p.game.y * p.map.lat, 0);
    const sumY2Z = REFERENCE_POINTS.reduce((acc, p) => acc + (p.game.y ** 2) * p.map.lat, 0);
    const sumY3Z = REFERENCE_POINTS.reduce((acc, p) => acc + (p.game.y ** 3) * p.map.lat, 0);
    const sumY4Z = REFERENCE_POINTS.reduce((acc, p) => acc + (p.game.y ** 4) * p.map.lat, 0);
  
    const n = REFERENCE_POINTS.length;
    const matrix = [
      [n, sumY, sumY2, sumY3, sumY4],
      [sumY, sumY2, sumY3, sumY4, sumY5],
      [sumY2, sumY3, sumY4, sumY5, sumY6],
      [sumY3, sumY4, sumY5, sumY6, sumY7],
      [sumY4, sumY5, sumY6, sumY7, sumY8]
    ];
    const constants = [sumZ, sumYZ, sumY2Z, sumY3Z, sumY4Z];
    
    // Solve for coefficients (a, b, c, d, e)
    const [e, d, c, b, a] = solveLinearSystem(matrix, constants);
    return { a, b, c, d, e };
  };

// Helper to solve linear systems
const solveLinearSystem = (
  matrix: number[][],
  constants: number[]
): number[] => {
  const n = constants.length;
  const augmented = matrix.map((row, i) => [...row, constants[i]]);

  // Forward elimination
  for (let i = 0; i < n; i++) {
    // Partial pivoting
    let maxRow = i;
    for (let j = i + 1; j < n; j++) {
      if (Math.abs(augmented[j][i]) > Math.abs(augmented[maxRow][i])) {
        maxRow = j;
      }
    }
    [augmented[i], augmented[maxRow]] = [augmented[maxRow], augmented[i]];

    // Eliminate lower triangle
    for (let j = i + 1; j < n; j++) {
      const factor = augmented[j][i] / augmented[i][i];
      for (let k = i; k <= n; k++) {
        augmented[j][k] -= factor * augmented[i][k];
      }
    }
  }

  // Back substitution
  const solution = new Array(n);
  for (let i = n - 1; i >= 0; i--) {
    solution[i] = augmented[i][n];
    for (let j = i + 1; j < n; j++) {
      solution[i] -= augmented[i][j] * solution[j];
    }
    solution[i] /= augmented[i][i];
  }

  return solution;
};

// Precompute coefficients
const LON_TRANSFORM = calculateLongitudeTransform();
const LAT_TRANSFORM = calculateLatitudeTransform();

export const gameToMap= (x: number, y: number): [number, number]  => {
    // Longitude: quadratic regression
    const lng = LON_TRANSFORM.a * x ** 2 + LON_TRANSFORM.b * x + LON_TRANSFORM.c;
    
    // Latitude: quartic regression
    const lat =
      LAT_TRANSFORM.a * y ** 4 +
      LAT_TRANSFORM.b * y ** 3 +
      LAT_TRANSFORM.c * y ** 2 +
      LAT_TRANSFORM.d * y +
      LAT_TRANSFORM.e;
    
    return [lng, lat] as [number, number];
  };
// Debug function to verify our conversion
export const testConversion = () => {
  let totalErrorLng = 0;
  let totalErrorLat = 0;

  REFERENCE_POINTS.forEach((point, index) => {
    const [lng, lat] = gameToMap(point.game.x, point.game.y);
    const errorLng = Math.abs(lng - point.map.lng);
    const errorLat = Math.abs(lat - point.map.lat);

    totalErrorLng += errorLng;
    totalErrorLat += errorLat;

    console.log(`\nReference Point ${index + 1}:`);
    console.log("Game:", point.game);
    console.log("Expected:", point.map);
    console.log("Got:", { lng: lng.toFixed(4), lat: lat.toFixed(4) });
    console.log("Error:", {
      lng: errorLng.toFixed(4),
      lat: errorLat.toFixed(4),
    });
  });

  console.log("\nAverage Error:", {
    lng: (totalErrorLng / REFERENCE_POINTS.length).toFixed(4),
    lat: (totalErrorLat / REFERENCE_POINTS.length).toFixed(4),
  });
};
