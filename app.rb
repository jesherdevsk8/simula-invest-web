# frozen_string_literal: true

# app.rb
require 'sinatra'
require 'sinatra/reloader' if development? # Recarrega o servidor em desenvolvimento

helpers do
  # Função para formatar valores monetários
  def formatar_moeda(valor)
    return 'R$ 0,00' if valor.nil? || !valor.is_a?(Numeric)

    format('R$ %.2f', valor).gsub('.', ',')
  end

  # Função para obter a alíquota do Imposto de Renda para CDBs
  def obter_aliquota_ir(prazo_em_dias)
    if prazo_em_dias <= 180
      0.225 # 22.5%
    elsif prazo_em_dias <= 360
      0.200 # 20.0%
    elsif prazo_em_dias <= 720
      0.175 # 17.5%
    else
      0.150 # 15.0%
    end
  end
end

get '/' do
  @titulo = 'Calculadora de Investimentos'
  @params_in = {} # Para manter os valores do formulário se houver recálculo
  @results = nil
  erb :index
end

post '/calculate' do
  @titulo = 'Resultado do Cálculo'
  @params_in = params # Guarda os parâmetros para preencher o formulário novamente

  tipo_investimento = params['tipo_investimento'].upcase
  valor_principal = params['valor_principal'].to_f
  percentual_cdi_investimento = params['percentual_cdi_investimento'].to_f
  taxa_cdi_anual = params['taxa_cdi_anual'].to_f
  prazo_meses = params['prazo_meses'].to_i

  # --- Cálculos ---
  taxa_bruta_anual_investimento = (percentual_cdi_investimento / 100.0) * (taxa_cdi_anual / 100.0)
  rendimento_bruto_total = valor_principal * taxa_bruta_anual_investimento * (prazo_meses / 12.0)

  aliquota_ir_aplicada = 0.0
  imposto_de_renda_valor = 0.0
  descricao_ir = 'LCI/LCA é isento de Imposto de Renda.'

  if tipo_investimento == 'CDB'
    prazo_em_dias = (prazo_meses / 12.0) * 365.0 # Estimativa base
    # Ajustes para prazos comuns para precisão na tabela IR
    prazo_em_dias = 180 if prazo_meses == 6
    prazo_em_dias = 365 if prazo_meses == 12
    prazo_em_dias = 547 if prazo_meses == 18 # (365 + 182.5)
    prazo_em_dias = 730 if prazo_meses == 24
    prazo_em_dias_calculado = prazo_em_dias.to_i

    aliquota_ir_aplicada = obter_aliquota_ir(prazo_em_dias_calculado)
    imposto_de_renda_valor = rendimento_bruto_total * aliquota_ir_aplicada
    descricao_ir = "Alíquota de IR para CDB (Prazo: #{prazo_em_dias_calculado} dias): #{(aliquota_ir_aplicada * 100).round(1)}%"
  end

  rendimento_liquido_total = rendimento_bruto_total - imposto_de_renda_valor
  valor_final_resgatado = valor_principal + rendimento_liquido_total

  taxa_liquida_efetiva_anualizada = 0.0
  if valor_principal.positive? && prazo_meses.positive?
    taxa_liquida_efetiva_periodo = (rendimento_liquido_total / valor_principal)
    taxa_liquida_efetiva_anualizada = (taxa_liquida_efetiva_periodo / (prazo_meses / 12.0)) * 100.0
  end

  @results = {
    tipo_investimento: tipo_investimento,
    valor_principal: valor_principal,
    percentual_cdi_investimento: percentual_cdi_investimento,
    taxa_cdi_anual: taxa_cdi_anual,
    prazo_meses: prazo_meses,
    taxa_bruta_anual_investimento_perc: (taxa_bruta_anual_investimento * 100),
    rendimento_bruto_total: rendimento_bruto_total,
    descricao_ir: descricao_ir,
    aliquota_ir_aplicada_perc: (aliquota_ir_aplicada * 100),
    imposto_de_renda_valor: imposto_de_renda_valor,
    rendimento_liquido_total: rendimento_liquido_total,
    valor_final_resgatado: valor_final_resgatado,
    taxa_liquida_efetiva_anualizada_perc: taxa_liquida_efetiva_anualizada
  }

  erb :index
end
