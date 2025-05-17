// public/js/scripts.js
function printContent(elementId) {
  const printableElement = document.getElementById(elementId);
  if (!printableElement) {
    console.error("Elemento para impressão não encontrado:", elementId);
    return;
  }

  // Remove qualquer stylesheet de impressão anterior para evitar duplicatas ou conflitos
  const existingPrintStyleSheet = document.getElementById('printStyleSheet');
  if (existingPrintStyleSheet) {
    existingPrintStyleSheet.remove();
  }

  const styleSheet = document.createElement('style');
  styleSheet.id = 'printStyleSheet'; // ID para fácil referência
  styleSheet.innerHTML = `
    @media print {
      body, html {
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important; /* Garante que o corpo ocupe a largura da página de impressão */
        height: auto !important; /* Altura automática */
        background-color: white !important; /* Fundo branco para impressão */
      }
      body * {
        visibility: hidden !important; /* Esconde tudo por padrão */
      }
      /* Torna a área imprimível e seus filhos visíveis */
      #${elementId}, #${elementId} * {
        visibility: visible !important;
      }
      /* Posiciona a área imprimível no topo da página de impressão */
      #${elementId} {
        position: absolute !important; /* Permite controle total da posição e tamanho */
        left: 0 !important;
        top: 0 !important;
        width: 100% !important; /* Ocupa a largura total da página de impressão */
        margin: 0 !important; /* Remove margens */
        padding: 20px !important; /* Adiciona um pouco de padding para não cortar conteúdo */
        border: none !important; /* Remove bordas do card na impressão */
        box-shadow: none !important; /* Remove sombras na impressão */
        background-color: white !important; /* Garante fundo branco para o card */
        font-size: 12pt !important; /* Tamanho de fonte adequado para impressão */
      }
      /* Esconde elementos marcados com .no-print */
      .no-print {
        display: none !important;
      }
      /* Estilos específicos para garantir que cores de fundo e texto sejam impressas */
      .card-header-custom {
        background: #0A4D8C !important; /* Cor sólida, gradientes podem não imprimir bem */
        color: white !important;
        -webkit-print-color-adjust: exact !important;
        color-adjust: exact !important;
        border-radius: 0 !important; /* Remove border-radius para impressão se desejado */
      }
      .results-title {
         color: #083A6A !important;
         -webkit-print-color-adjust: exact !important;
         color-adjust: exact !important;
         margin-top: 0 !important; /* Ajusta margem superior para impressão */
      }
      .list-group-item-highlight {
        background-color: #e7f0f9 !important;
        -webkit-print-color-adjust: exact !important;
        color-adjust: exact !important;
      }
      .list-group-item strong {
        color: #0A4D8C !important;
         -webkit-print-color-adjust: exact !important;
         color-adjust: exact !important;
      }
      .list-group-item-highlight strong {
         color: #083A6A !important;
         -webkit-print-color-adjust: exact !important;
         color-adjust: exact !important;
      }
      .text-danger {
        color: #dc3545 !important;
        -webkit-print-color-adjust: exact !important;
        color-adjust: exact !important;
      }
      span[style*="color: #28a745"], span[style*="color: #198754"] {
        -webkit-print-color-adjust: exact !important;
        color-adjust: exact !important;
      }
      /* Evita quebras de página indesejadas dentro de elementos */
      .list-group-item, .card-body, .results-card {
        page-break-inside: avoid !important;
      }
      h4, h5 {
        page-break-after: avoid !important;
      }
    }
  `;
  document.head.appendChild(styleSheet);
  window.print();
}