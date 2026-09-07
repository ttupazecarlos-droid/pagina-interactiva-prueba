// ============================================================
// EL PUENTE DIGITAL — E-business & E-commerce
// ------------------------------------------------------------
// Tia Óleo consulta el tipo de cambio del día (Soles -> otras
// monedas) usando una API pública GRATUITA y SIN API KEY. Con las
// tasas obtenidas, el menú de la cabecera convierte los precios del
// catálogo a la moneda elegida en tiempo real.
//
// API utilizada: open.er-api.com (Exchange Rate API - Open Access)
// Documentación: https://www.exchangerate-api.com/docs/free
// ============================================================

const API_TIPO_CAMBIO = "https://open.er-api.com/v6/latest/PEN";

/**
 * Obtiene las tasas de cambio actuales desde la API externa.
 * @returns {Promise<Object>} objeto con tasas, ej: { USD: 0.27, EUR: 0.25, ... }
 */
async function obtenerTasasDeCambio() {
  const respuesta = await fetch(API_TIPO_CAMBIO);

  if (!respuesta.ok) {
    throw new Error(`La API respondió con error: ${respuesta.status}`);
  }

  const datos = await respuesta.json();

  if (datos.result !== "success") {
    throw new Error("La API no devolvió tasas de cambio válidas.");
  }

  return datos.rates;
}