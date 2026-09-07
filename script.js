
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

    // Mostrar/ocultar botón según scroll
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
