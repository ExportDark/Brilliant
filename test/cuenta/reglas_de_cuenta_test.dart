import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/reglas_de_cuenta.dart';

void main() {
  group('problemaConElUsuario', () {
    for (final bueno in ['ana', 'a' * 20, 'Ana_1.x-2', '007', 'luz.del-sol']) {
      test('acepta "$bueno"', () => expect(problemaConElUsuario(bueno), isNull));
    }

    test('vacío: pide elegir uno', () {
      expect(problemaConElUsuario(''), 'Elige un nombre de usuario');
    });

    for (final (usuario, porQue) in [
      ('an', 'tiene 2'),
      ('a' * 21, 'tiene 21'),
      ('a' * 500, 'tiene 500'),
    ]) {
      test('rechaza el largo si $porQue', () {
        expect(problemaConElUsuario(usuario), usuarioDeOtroLargo);
      });
    }

    for (final (usuario, porQue) in [
      ('ana pérez', 'un espacio y un acento'),
      ('аna', 'una "а" cirílica que se parece'),
      ('ana@correo', 'una arroba'),
      ('ana+1', 'un más'),
      ('ñandu', 'una ñ'),
      ('josé', 'un acento'),
      ('ana💎', 'un emoji'),
      ('<script>', 'código'),
      ("' OR 1=1 --", 'una inyección de SQL'),
      ('ana\tclara', 'un tab'),
      ('ana\nclara', 'un salto de línea'),
      ('ana\x00', 'un carácter nulo'),
    ]) {
      test('rechaza los caracteres raros: $porQue', () {
        expect(problemaConElUsuario(usuario), usuarioConCaracteresRaros);
      });
    }

    test('cuenta caracteres, no unidades de UTF-16, como el servidor', () {
      // 19 letras y un emoji son 20 caracteres: lo malo es el emoji, no el largo.
      expect(problemaConElUsuario('${'a' * 19}💎'), usuarioConCaracteresRaros);
    });
  });

  group('problemaConLaContrasena', () {
    test('vacía: pide elegir una', () {
      expect(problemaConLaContrasena(''), 'Elige una contraseña');
    });

    test('de 7 caracteres es corta, de 8 está bien', () {
      expect(problemaConLaContrasena('a' * 7), 'Al menos 8 caracteres');
      expect(problemaConLaContrasena('a' * 8), isNull);
    });

    test('de 128 caracteres está bien, de 129 es larga', () {
      expect(problemaConLaContrasena('a' * 128), isNull);
      expect(problemaConLaContrasena('a' * 129), 'Como mucho 128 caracteres');
    });

    test('los espacios del borde, la ñ, los acentos y los emojis cuentan como parte de ella', () {
      expect(problemaConLaContrasena('  piñata mágica 💎  '), isNull);
      // 3 espacios, 2 emojis y 3 espacios: 8 caracteres, aunque en UTF-16 sean 10.
      expect(problemaConLaContrasena('   💎💎   '), isNull);
      expect(problemaConLaContrasena('   💎💎  '), 'Al menos 8 caracteres');
    });
  });
}
