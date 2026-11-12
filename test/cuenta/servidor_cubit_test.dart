import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/servidor_state.dart';

import 'ayudantes_cuenta.dart';

void main() {
  final deSiempre = Uri.parse('https://servidor.test:8443/');
  final nueva = Uri.parse('https://192.168.137.252:8443/');

  late ServidorFalso servidor;
  late AlmacenEnMemoria almacen;
  late BuscadorFalso buscador;

  setUp(() {
    servidor = ServidorFalso();
    almacen = AlmacenEnMemoria();
    buscador = BuscadorFalso();
  });

  ServidorCubit nuevoCubit({BuscadorDeServidores? conBuscador, Duration? reintentarCada}) =>
      ServidorCubit(
        servidor.cliente(),
        almacen,
        buscador: conBuscador ?? buscador,
        reintentarCada: reintentarCada,
      );

  /// Un cubit creado con la dirección de siempre, y luego la PC cambió de
  /// red: ahí ya no contesta nadie.
  ServidorCubit cubitConLaPcEnOtraRed() {
    final cubit = nuevoCubit();
    servidor.direccion = '192.168.137.252';
    return cubit;
  }

  ServidorState estado(Uri direccion, Disponibilidad disponibilidad, [String? nombre]) =>
      ServidorState(direccion: direccion, disponibilidad: disponibilidad, nombre: nombre);

  group('ServidorCubit al revisar', () {
    test('empieza revisando la dirección de partida', () {
      final cubit = nuevoCubit();
      addTearDown(cubit.close);

      expect(cubit.state, estado(deSiempre, Disponibilidad.revisando));
      expect(cubit.porDefecto, deSiempre);
    });

    blocTest<ServidorCubit, ServidorState>(
      'si contesta, está disponible, sin buscar',
      build: nuevoCubit,
      act: (cubit) => cubit.revisar(),
      expect: () => [estado(deSiempre, Disponibilidad.disponible)],
      verify: (_) => expect(buscador.busquedas, 0),
    );

    blocTest<ServidorCubit, ServidorState>(
      'primero carga la dirección que eligió el jugador',
      build: () {
        almacen.servidor = nueva;
        return cubitConLaPcEnOtraRed();
      },
      act: (cubit) => cubit.revisar(),
      expect: () => [
        estado(nueva, Disponibilidad.revisando),
        estado(nueva, Disponibilidad.disponible),
      ],
    );

    blocTest<ServidorCubit, ServidorState>(
      'si no contesta, lo busca en la red, y si hay uno se cambia a él y lo recuerda',
      build: () {
        buscador.anunciados.add(anunciado('192.168.137.252'));
        return cubitConLaPcEnOtraRed();
      },
      act: (cubit) => cubit.revisar(),
      expect: () => [
        estado(nueva, Disponibilidad.revisando, 'Brilliant en ORION'),
        estado(nueva, Disponibilidad.disponible, 'Brilliant en ORION'),
      ],
      verify: (_) => expect(almacen.servidor, nueva),
    );

    blocTest<ServidorCubit, ServidorState>(
      'si no contesta y en la red no hay ninguno, no está disponible',
      build: cubitConLaPcEnOtraRed,
      act: (cubit) => cubit.revisar(),
      expect: () => [estado(deSiempre, Disponibilidad.noDisponible)],
      verify: (_) => expect(buscador.busquedas, 1),
    );

    blocTest<ServidorCubit, ServidorState>(
      'si en la red contestan varios, no elige',
      build: () {
        servidor.otrasDirecciones.add('192.168.137.40');
        buscador.anunciados.addAll([
          anunciado('192.168.137.252'),
          anunciado('192.168.137.40', pc: 'VEGA'),
        ]);
        return cubitConLaPcEnOtraRed();
      },
      act: (cubit) => cubit.revisar(),
      expect: () => [
        ServidorState(
          direccion: deSiempre,
          disponibilidad: Disponibilidad.variosEncontrados,
          encontrados: [
            anunciado('192.168.137.252'),
            anunciado('192.168.137.40', pc: 'VEGA'),
          ],
        ),
      ],
      verify: (_) => expect(almacen.servidor, isNull),
    );

    test('con varios en la red, el jugador elige uno de la lista y queda disponible', () async {
      servidor.otrasDirecciones.add('192.168.137.40');
      buscador.anunciados.addAll([
        anunciado('192.168.137.252'),
        anunciado('192.168.137.40', pc: 'VEGA'),
      ]);
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);
      await cubit.revisar();
      expect(cubit.state.disponibilidad, Disponibilidad.variosEncontrados);

      final vega = cubit.state.encontrados.last;
      await cubit.elegir(vega.direccion, nombre: vega.nombre);

      expect(cubit.state.disponibilidad, Disponibilidad.disponible);
      expect(cubit.state.direccion, vega.direccion);
      expect(cubit.state.encontrados, isEmpty);
      expect(almacen.servidor, vega.direccion);
    });

    test('"Buscar de nuevo" encuentra uno que se encendió después, y se cambia a él', () async {
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);
      await cubit.revisar();
      expect(cubit.state.disponibilidad, Disponibilidad.noDisponible);

      buscador.anunciados.add(anunciado('192.168.137.252'));
      await cubit.buscarEnLaRed();

      expect(cubit.state.disponibilidad, Disponibilidad.disponible);
      expect(cubit.state.direccion, nueva);
    });

    test('si de varios solo queda uno al buscar de nuevo, la lista desaparece', () async {
      servidor.otrasDirecciones.add('192.168.137.40');
      buscador.anunciados.addAll([
        anunciado('192.168.137.252'),
        anunciado('192.168.137.40', pc: 'VEGA'),
      ]);
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);
      await cubit.revisar();
      expect(cubit.state.encontrados, hasLength(2));

      servidor.otrasDirecciones.clear();
      await cubit.buscarEnLaRed();

      expect(cubit.state.encontrados, isEmpty);
      expect(cubit.state.disponibilidad, Disponibilidad.disponible);
    });

    test('si de varios ninguno contesta al buscar de nuevo, vuelve a "sin servidor"', () async {
      servidor.otrasDirecciones.add('192.168.137.40');
      buscador.anunciados.addAll([
        anunciado('192.168.137.252'),
        anunciado('192.168.137.40', pc: 'VEGA'),
      ]);
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);
      await cubit.revisar();

      servidor.apagado = true;
      await cubit.buscarEnLaRed();

      expect(cubit.state.disponibilidad, Disponibilidad.noDisponible);
      expect(cubit.state.encontrados, isEmpty);
    });

    blocTest<ServidorCubit, ServidorState>(
      'sin buscador, como en la web, solo revisa la dirección que tiene',
      build: () {
        final cubit = nuevoCubit(conBuscador: const SinBuscar());
        servidor.apagado = true;
        return cubit;
      },
      act: (cubit) => cubit.revisar(),
      expect: () => [estado(deSiempre, Disponibilidad.noDisponible)],
      verify: (cubit) => expect(cubit.puedeBuscar, isFalse),
    );

    test('mientras no hay servidor, vuelve a revisar solo, y nota cuando se enciende', () async {
      servidor.apagado = true;
      final cubit = nuevoCubit(reintentarCada: const Duration(milliseconds: 20));
      addTearDown(cubit.close);

      await cubit.revisar();
      expect(cubit.state.disponibilidad, Disponibilidad.noDisponible);

      servidor.apagado = false;
      await cubit.stream.firstWhere((s) => s.disponibilidad == Disponibilidad.disponible);
    });

    test('dos revisiones pedidas antes de empezar son una sola', () async {
      final cubit = nuevoCubit();
      addTearDown(cubit.close);

      await Future.wait([cubit.revisar(), cubit.revisar()]);

      expect(servidor.pedidos, hasLength(1));
    });
  });

  group('ServidorCubit al elegir', () {
    blocTest<ServidorCubit, ServidorState>(
      'una dirección: la guarda y revisa que conteste',
      build: cubitConLaPcEnOtraRed,
      act: (cubit) => cubit.elegir(nueva),
      expect: () => [
        estado(nueva, Disponibilidad.revisando),
        estado(nueva, Disponibilidad.disponible),
      ],
      verify: (_) => expect(almacen.servidor, nueva),
    );

    blocTest<ServidorCubit, ServidorState>(
      'uno de los encontrados en la red, con su nombre',
      build: cubitConLaPcEnOtraRed,
      act: (cubit) => cubit.elegir(nueva, nombre: 'Brilliant en ORION'),
      expect: () => [
        estado(nueva, Disponibilidad.revisando, 'Brilliant en ORION'),
        estado(nueva, Disponibilidad.disponible, 'Brilliant en ORION'),
      ],
    );

    blocTest<ServidorCubit, ServidorState>(
      'si ahí no contesta nadie, la guarda igual y no está disponible',
      build: nuevoCubit,
      act: (cubit) => cubit.elegir(Uri.parse('https://10.0.0.9:8443/')),
      expect: () => [
        estado(Uri.parse('https://10.0.0.9:8443/'), Disponibilidad.revisando),
        estado(Uri.parse('https://10.0.0.9:8443/'), Disponibilidad.noDisponible),
      ],
      verify: (_) => expect(almacen.servidor, Uri.parse('https://10.0.0.9:8443/')),
    );

    blocTest<ServidorCubit, ServidorState>(
      'restablecer vuelve a la de partida y olvida la elegida',
      build: () {
        almacen.servidor = nueva;
        return nuevoCubit();
      },
      act: (cubit) => cubit.elegir(null),
      skip: 1,
      expect: () => [
        estado(deSiempre, Disponibilidad.revisando),
        estado(deSiempre, Disponibilidad.disponible),
      ],
      verify: (_) => expect(almacen.servidor, isNull),
    );
  });

  group('ServidorCubit cuando la sesión no llegó al servidor', () {
    blocTest<ServidorCubit, ServidorState>(
      'buscarOtro se cambia al único que contesta y lo devuelve',
      build: () {
        buscador.anunciados.add(anunciado('192.168.137.252'));
        return cubitConLaPcEnOtraRed();
      },
      act: (cubit) async {
        expect(await cubit.buscarOtro(deSiempre), [anunciado('192.168.137.252')]);
      },
      verify: (cubit) => expect(cubit.state.direccion, nueva),
    );

    test('si mientras tanto ya se cambió a otro que contesta, no vuelve a buscar', () async {
      buscador.anunciados.add(anunciado('192.168.137.252'));
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);
      await cubit.revisar();
      expect(buscador.busquedas, 1);

      final encontrados = await cubit.buscarOtro(deSiempre);

      expect(encontrados.single.direccion, nueva);
      expect(buscador.busquedas, 1);
    });

    blocTest<ServidorCubit, ServidorState>(
      'contesto() lo marca disponible',
      build: nuevoCubit,
      act: (cubit) => cubit.contesto(),
      expect: () => [estado(deSiempre, Disponibilidad.disponible)],
    );
  });

  group('ServidorCubit.buscarServidores', () {
    test('un servidor que se anuncia con varias IPs aparece una vez, con la que contesta', () async {
      buscador.anunciados.addAll([anunciado('10.0.0.9'), anunciado('192.168.137.252')]);
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      expect(await cubit.buscarServidores(), [anunciado('192.168.137.252')]);
    });

    test('los que se anuncian pero no contestan no aparecen', () async {
      buscador.anunciados.add(anunciado('10.0.0.9', pc: 'VEGA'));
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      expect(await cubit.buscarServidores(), isEmpty);
    });

    test('uno encontrado probando direcciones (sin nombre) le pregunta su nombre al servidor',
        () async {
      servidor.nombres['192.168.137.252'] = 'Brilliant en VEGA';
      buscador.anunciados.add(
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.137.252:8443/')),
      );
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      expect(await cubit.buscarServidores(), [anunciado('192.168.137.252', pc: 'VEGA')]);
    });

    test('si el servidor no dice su nombre (uno de antes), se llama por su IP', () async {
      servidor.sinRutaDeNombre = true;
      buscador.anunciados.add(
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.137.252:8443/')),
      );
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      final encontrados = await cubit.buscarServidores();

      expect(encontrados.single.nombre, 'Brilliant en 192.168.137.252');
    });

    test('el mismo servidor encontrado por mDNS y probando direcciones aparece una vez, con '
        'el nombre del anuncio', () async {
      buscador.anunciados.addAll([
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.137.252:8443/')),
        anunciado('192.168.137.252'),
      ]);
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      expect(await cubit.buscarServidores(), [anunciado('192.168.137.252')]);
    });

    test('al revisar, si el único que contesta salió de probar direcciones, se cambia a él',
        () async {
      buscador.anunciados.add(
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.137.252:8443/')),
      );
      final cubit = cubitConLaPcEnOtraRed();
      addTearDown(cubit.close);

      await cubit.revisar();

      expect(cubit.state.disponibilidad, Disponibilidad.disponible);
      expect(cubit.state.direccion, nueva);
      expect(cubit.state.nombre, 'Brilliant en ORION');
    });
  });
}
