import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/almacen_de_sesion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AlmacenSeguro guarda y lee varias sesiones por cerrar, y vacía las borra', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const almacen = AlmacenSeguro();

    await almacen.guardarPorCerrar(const [
      Sesion(usuario: 'ana', token: 't-ana'),
      Sesion(usuario: 'beto', token: 't-beto'),
    ]);
    final leidas = await almacen.leerPorCerrar();
    expect([for (final s in leidas) '${s.usuario}:${s.token}'], ['ana:t-ana', 'beto:t-beto']);

    await almacen.guardarPorCerrar(const []);
    expect(await almacen.leerPorCerrar(), isEmpty);
  });

  test('AlmacenSeguro no pierde la sesión por cerrar que se guardó con la versión anterior',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'porcerrar.usuario': 'ana',
      'porcerrar.token': 't-ana',
    });
    const almacen = AlmacenSeguro();

    final leidas = await almacen.leerPorCerrar();
    expect(leidas.single.usuario, 'ana');

    // Al guardar la lista, las claves viejas se borran: no se vuelve a leer dos veces.
    await almacen.guardarPorCerrar(leidas);
    expect((await almacen.leerPorCerrar()).length, 1);
  });
}
