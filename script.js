
    let currentSlide = 0;
    const slides = document.querySelectorAll('.carousel-item');
    const indicators = document.querySelectorAll('.indicator');
    const totalSlides = slides.length;
    let autoSlideInterval;

    function showSlide(index) {
      if (index >= totalSlides) currentSlide = 0;
      else if (index < 0) currentSlide = totalSlides - 1;
      else currentSlide = index;

      const offset = -currentSlide * 100;
      document.querySelector('.carousel-inner').style.transform = `translateX(${offset}%)`;

      indicators.forEach((ind, i) => {
        ind.classList.toggle('active', i === currentSlide);
      });
    }

    function nextSlide() {
      showSlide(currentSlide + 1);
      resetAutoSlide();
    }

    function previousSlide() {
      showSlide(currentSlide - 1);
      resetAutoSlide();
    }

    function goToSlide(index) {
      showSlide(index);
      resetAutoSlide();
    }

    function startAutoSlide() {
      autoSlideInterval = setInterval(() => {
        nextSlide();
      }, 5000);
    }

    function resetAutoSlide() {
      clearInterval(autoSlideInterval);
      startAutoSlide();
    }

    startAutoSlide();

    // ========== BOTON FLOTANTE PARA IR AL INICIO ==========
    const btnInicio = document.getElementById('btnInicio');

    window.addEventListener('scroll', () => {
      if (window.pageYOffset > 300) {
        btnInicio.classList.add('visible');
      } else {
        btnInicio.classList.remove('visible');
      }
    });

    function irAlInicio() {
      const target = document.querySelector('#inicio');
      if (target) {
        const navHeight = document.querySelector('nav').offsetHeight;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navHeight;
        
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      }
    }

    // Smooth scroll para navegacion
    document.querySelectorAll('nav a').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const targetId = this.getAttribute('href');
        const target = document.querySelector(targetId);
        
        if (target) {
          const navHeight = document.querySelector('nav').offsetHeight;
          const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navHeight;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      });
    });

    // ========== FUNCION PARA ENVIAR A WHATSAPP ==========
    function enviarWhatsApp(event, nombreProducto) {
      event.preventDefault();

      const numeroWhatsApp = '51993706366';

      const mensaje = `Hola, estoy interesado en: *${nombreProducto}*. Podrias darme mas informacion?`;

      const mensajeCodificado = encodeURIComponent(mensaje);

      const urlWhatsApp = `https://wa.me/${numeroWhatsApp}?text=${mensajeCodificado}`;

      window.open(urlWhatsApp, '_blank');
    }

    // ========== MENÚ FLOTANTE DE CAMBIO DE MONEDA ==========
    // Al pulsar "Cambiar moneda" se consulta la API externa
    // (open.er-api.com) y se despliega un menú flotante con las monedas
    // disponibles. Al elegir una, cada producto del catálogo de la página
    // principal se convierte a esa moneda en tiempo real.
    // Reutiliza obtenerTasasDeCambio(), definida en puente-digital.js.

    // Mapa CÓDIGO -> { país (es), símbolo } para las monedas más comunes.
    const PAISES_MONEDA = {
      PEN: { pais: 'Perú (Soles)', simbolo: 'S/' },
      USD: { pais: 'Estados Unidos', simbolo: '$' },
      EUR: { pais: 'Unión Europea', simbolo: '€' },
      MXN: { pais: 'México', simbolo: 'MX$' },
      CLP: { pais: 'Chile', simbolo: 'CLP$' },
      ARS: { pais: 'Argentina', simbolo: 'AR$' },
      COP: { pais: 'Colombia', simbolo: 'COP$' },
      BRL: { pais: 'Brasil', simbolo: 'R$' },
      BOB: { pais: 'Bolivia', simbolo: 'Bs' },
      PYG: { pais: 'Paraguay', simbolo: 'Gs' },
      UYU: { pais: 'Uruguay', simbolo: '$U' },
      VES: { pais: 'Venezuela', simbolo: 'Bs' },
      GBP: { pais: 'Reino Unido', simbolo: '£' },
      JPY: { pais: 'Japón', simbolo: '¥' },
      CAD: { pais: 'Canadá', simbolo: 'CA$' },
      AUD: { pais: 'Australia', simbolo: 'A$' },
      CHF: { pais: 'Suiza', simbolo: 'CHF' },
      CNY: { pais: 'China', simbolo: 'CN¥' },
      KRW: { pais: 'Corea del Sur', simbolo: '₩' }
    };

    let tasasActuales = null;

    // Obtiene (y cachea) las tasas usando la API del Puente Digital.
    async function obtenerTasas() {
      if (tasasActuales) return tasasActuales;
      tasasActuales = await obtenerTasasDeCambio();
      return tasasActuales;
    }

    function formatearSimbolo(codigo) {
      const info = PAISES_MONEDA[codigo];
      return info ? info.simbolo : codigo;
    }

    function nombrePais(codigo) {
      const info = PAISES_MONEDA[codigo];
      return info ? info.pais : codigo;
    }

    // Devuelve las monedas disponibles: las que la API devuelve y tenemos
    // traducidas. PEN (Soles) va siempre primero para poder volver a los
    // precios originales.
    function monedasDisponibles(tasas) {
      return ['PEN'].concat(
        Object.keys(PAISES_MONEDA).filter(
          (c) => c !== 'PEN' && typeof tasas[c] === 'number' && tasas[c] > 0
        )
      );
    }

    // Abre/cierra el menú flotante y muestra las monedas disponibles.
    async function alternarMenuMonedas() {
      const menu = document.getElementById('menuMonedas');
      if (!menu) return;

      if (menu.classList.contains('abierto')) {
        cerrarMenuMonedas();
        return;
      }

      menu.classList.add('cargando');
      menu.innerHTML = '<div class="menu-monedas-estado">Consultando tipo de cambio...</div>';
      menu.classList.add('abierto');

      try {
        const tasas = await obtenerTasas();
        const monedas = monedasDisponibles(tasas);
        renderizarMenuMonedas(menu, monedas, tasas);
      } catch (error) {
        menu.innerHTML =
          '<div class="menu-monedas-estado error">No se pudo conectar con la API externa.</div>';
      }
    }

    function renderizarMenuMonedas(menu, monedas, tasas) {
      const items = monedas
        .map((codigo) => {
          const simbolo = formatearSimbolo(codigo);
          const pais = nombrePais(codigo);
          const tasa = tasas[codigo];
          return (
            '<button type="button" class="menu-monedas-item" onclick="elegirMoneda(\'' +
            codigo +
            '\')">' +
            '<span class="mm-simbolo">' +
            simbolo +
            '</span>' +
            '<span class="mm-nombre">' +
            pais +
            '</span>' +
            '<span class="mm-valor">1 PEN = ' +
            tasa.toFixed(4) +
            '</span>' +
            '</button>'
          );
        })
        .join('');

      menu.innerHTML =
        '<div class="menu-monedas-titulo">Monedas disponibles</div>' + items;
    }

    function cerrarMenuMonedas() {
      const menu = document.getElementById('menuMonedas');
      if (menu) {
        menu.classList.remove('abierto');
        menu.classList.remove('cargando');
      }
    }

    // Actualiza el precio visible de cada tarjeta del catálogo principal.
    // opcion = null restaura el precio original en Soles (PEN).
    function aplicarMonedaACatalogo(opcion) {
      const precios = document.querySelectorAll('#catalogo .card .precio');
      precios.forEach((el) => {
        const precioPEN = parseFloat(el.getAttribute('data-precio'));
        if (!opcion) {
          el.textContent = 'S/ ' + precioPEN.toFixed(2);
        } else {
          el.textContent =
            opcion.simbolo + ' ' + (precioPEN * opcion.tasa).toFixed(2);
        }
      });
    }

    // Convierte el catálogo a la moneda elegida y cierra el menú.
    async function elegirMoneda(codigo) {
      cerrarMenuMonedas();

      const tasas = await obtenerTasas();

      // PEN restaura los precios originales en Soles.
      if (codigo === 'PEN') {
        aplicarMonedaACatalogo(null);
        return;
      }

      const tasa = tasas[codigo];
      if (typeof tasa !== 'number') return;

      aplicarMonedaACatalogo({
        codigo,
        simbolo: formatearSimbolo(codigo),
        tasa
      });
    }

    // Cerrar el menú al hacer clic fuera de él.
    document.addEventListener('click', (evento) => {
      const wrapper = document.querySelector('.nav-moneda-wrapper');
      const menu = document.getElementById('menuMonedas');
      if (wrapper && menu && menu.classList.contains('abierto')) {
        if (!wrapper.contains(evento.target)) {
          cerrarMenuMonedas();
        }
      }
    });

    // ========== CATÁLOGO GENERADO DESDE PRODUCTOS-DATA.JS ==========
    // Los productos, precios, descripciones e imágenes viven SOLO en
    // productos-data.js. Este generador construye el HTML de las
    // tarjetas para que no haya que editar el catálogo en el HTML.
    (function renderizarCatalogo() {
      const contenedor = document.getElementById('catalogo');
      if (!contenedor || typeof productos === 'undefined') return;

      const categorias = [
        { id: 'papeles', titulo: 'Papeles y Blocs' },
        { id: 'cuadernos', titulo: 'Cuadernos y Croqueras' },
        { id: 'pinturas', titulo: 'Pinturas' },
        { id: 'pinceles', titulo: 'Pinceles y Marcadores' },
        { id: 'lapices', titulo: 'Lápices de Colores' }
      ];

      const iconoWhatsApp =
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/></svg>';

      function tarjeta(p) {
        const nombreEscapado = String(p.nombre).replace(/'/g, "\\'");
        return (
          '<div class="card" data-precio="' +
          p.precio +
          '">' +
          '<div class="card-carousel">' +
          '<div class="card-carousel-inner">' +
          '<div class="card-carousel-item">' +
          '<img loading="lazy" src="' +
          p.imagen +
          '" alt="' +
          p.nombre +
          '">' +
          '</div>' +
          '</div>' +
          '</div>' +
          '<div class="info">' +
          '<div class="card-info-item active">' +
          '<h3>' +
          p.nombre +
          '</h3>' +
          '<p>' +
          p.descripcion +
          '</p>' +
          '<p class="precio" data-precio="' +
          p.precio +
          '">S/ ' +
          p.precio.toFixed(2) +
          '</p>' +
          '<a href="#" class="btn-whatsapp" onclick="enviarWhatsApp(event, \'' +
          nombreEscapado +
          '\')">' +
          iconoWhatsApp +
          ' Consultar' +
          '</a>' +
          '</div>' +
          '</div>' +
          '</div>'
        );
      }

      contenedor.innerHTML = categorias
        .map(function (cat) {
          const items = productos
            .filter(function (p) {
              return p.categoria === cat.titulo;
            })
            .map(tarjeta)
            .join('');
          return (
            '<section id="' +
            cat.id +
            '"><h2>' +
            cat.titulo +
            '</h2><div class="grid">' +
            items +
            '</div></section>'
          );
        })
        .join('');
    })();
