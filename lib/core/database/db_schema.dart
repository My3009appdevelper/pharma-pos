// lib/core/database/db_schema.dart

class DBSchema {
  static const String createProductos = '''
  CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo_barra TEXT UNIQUE,
    nombre TEXT,
    descripcion TEXT,
    categorias TEXT,
    unidad_medida TEXT,
    precio_venta REAL,
    precio_compra REAL,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    lote TEXT,
    caducidad TEXT,
    imagen_url TEXT,
    temperatura_minima REAL,
    temperatura_maxima REAL,
    humedad_maxima REAL,
    requiere_refrigeracion INTEGER,
    requiere_receta INTEGER,
    cantidad_vendida_historico INTEGER,
    ultima_venta TEXT,
    veces_en_promocion INTEGER,
    codigo_sat TEXT,
    presentacion TEXT,
    ubicacion_fisica TEXT,
    productos_relacionados TEXT,      -- JSON: ['codigo1', 'codigo2']
    comprados_junto_a TEXT,           -- JSON: ['codigo1', 'codigo2']
    activo INTEGER DEFAULT 1,
    fecha_creado TEXT,
    actualizado INTEGER DEFAULT 0
  );
''';

  static const String createUsuarios = '''
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT,
    nombre_completo TEXT,
    rol TEXT,
    id_sucursal INTEGER,
    activo INTEGER DEFAULT 1,
    FOREIGN KEY(id_sucursal) REFERENCES sucursales(id)
  );
''';

  static const String createMovimientosStock = '''
    CREATE TABLE IF NOT EXISTS movimientos_stock (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_producto INTEGER,
      tipo TEXT,
      cantidad INTEGER,
      motivo TEXT,
      fecha TEXT,
      sincronizado INTEGER DEFAULT 0,
      FOREIGN KEY(id_producto) REFERENCES productos(id)
    );
  ''';

  static const String createSyncLog = '''
    CREATE TABLE IF NOT EXISTS sync_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tabla_afectada TEXT,
      id_local INTEGER,
      accion TEXT,
      fecha TEXT
    );
  ''';

  static const String createClientes = '''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid_cliente TEXT UNIQUE,
      nombreCompleto TEXT NOT NULL,
      apellido TEXT,
      telefono TEXT,
      email TEXT,
      direccion TEXT,
      ciudad TEXT,
      estado TEXT,
      codigo_postal TEXT,
      creadoEn TEXT,
      modificadoEn TEXT,
      rfc TEXT,
      razonSocial TEXT,
      usoCfdi TEXT,
      regimenFiscal TEXT,
      puntosAcumulados INTEGER DEFAULT 0
    );
  ''';

  static const String createSucursales = '''
    CREATE TABLE IF NOT EXISTS sucursales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT,
      direccion TEXT,
      telefono TEXT,
      ciudad TEXT,
      estado TEXT
    );
  ''';

  static const String createInventarioSucursal = '''
  CREATE TABLE IF NOT EXISTS inventario_sucursal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_producto INTEGER,
    id_sucursal INTEGER,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    lote TEXT,
    caducidad TEXT,
    fecha_entrada TEXT,
    precio_compra REAL,
    precio_venta REAL,
    activo INTEGER DEFAULT 1,
    ubicacion_fisica TEXT,
    presentacion TEXT,
    FOREIGN KEY(id_producto) REFERENCES productos(id),
    FOREIGN KEY(id_sucursal) REFERENCES sucursales(id)
  );
''';

  static const String createLotesProducto = '''
    CREATE TABLE IF NOT EXISTS lotes_producto (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  id_producto INTEGER,
  id_sucursal INTEGER,
  lote TEXT,
  fecha_entrada TEXT,
  fecha_caducidad TEXT,
  stock INTEGER,
  precio_compra REAL,
  precio_venta REAL,
  activo INTEGER DEFAULT 1,
  FOREIGN KEY(id_producto) REFERENCES productos(id),
  FOREIGN KEY(id_sucursal) REFERENCES sucursales(id)
);
  ''';

  static const String createVentas = '''
  CREATE TABLE IF NOT EXISTS ventas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE,
    folio TEXT UNIQUE,
    fecha TEXT,
    id_usuario INTEGER,
    id_sucursal INTEGER,
    uuid_cliente TEXT,
    total REAL,
    subtotal REAL,
    descuento_total REAL,
    metodo_pago TEXT,
    creado_en TEXT,
    modificado_en TEXT,
    observaciones TEXT,
    sincronizado INTEGER DEFAULT 0,
    FOREIGN KEY(id_usuario) REFERENCES usuarios(id) ON DELETE SET NULL,
    FOREIGN KEY(id_sucursal) REFERENCES sucursales(id) ON DELETE SET NULL,
    FOREIGN KEY(uuid_cliente) REFERENCES clientes(uuid_cliente) ON DELETE SET NULL
  );
''';

  static const String createVentaDetalle = '''
  CREATE TABLE IF NOT EXISTS venta_detalle (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid_venta TEXT,
    id_producto INTEGER,
    cantidad INTEGER,
    precio_unitario REAL,
    descuento REAL DEFAULT 0,
    total REAL,
    id_sucursal INTEGER,
    creado_en TEXT,
    modificado_en TEXT,
    sincronizado INTEGER DEFAULT 0,
    FOREIGN KEY(uuid_venta) REFERENCES ventas(uuid),
    FOREIGN KEY(id_producto) REFERENCES productos(id),
    FOREIGN KEY(id_producto) REFERENCES sucursales(id)
  );
''';

  static const String createRecetas = '''
  CREATE TABLE IF NOT EXISTS recetas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE,
    uuid_venta TEXT,
    uuid_cliente TEXT,
    nombre_paciente TEXT,
    nombre_medico TEXT,
    cedula_profesional TEXT,
    observaciones TEXT,
    fecha_emision TEXT,
    creado_en TEXT,
    modificado_en TEXT,
    sincronizado INTEGER DEFAULT 0,
    FOREIGN KEY(uuid_venta) REFERENCES ventas(uuid),
    FOREIGN KEY(uuid_cliente) REFERENCES clientes(uuid_cliente)
  );
''';

  static const String createRecetaDetalle = '''
  CREATE TABLE IF NOT EXISTS receta_detalle (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid_receta TEXT,
    id_producto INTEGER,
    cantidad INTEGER,
    indicaciones TEXT,
    creado_en TEXT,
    modificado_en TEXT,
    sincronizado INTEGER DEFAULT 0,
    FOREIGN KEY(uuid_receta) REFERENCES recetas(uuid),
    FOREIGN KEY(id_producto) REFERENCES productos(id)
  );
''';
}
