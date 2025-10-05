defmodule MatricesYListas do
  def main do
    lista = [1, 2, 3, 4, 5, 6]
    IO.puts("Elementos pares en la lista #{inspect(lista)}: #{elementos_pares(lista)} elementos")

    lista2 = [10, 20, 30, 40]
    IO.puts("Lista invertida sin Enum.reverse: #{inspect(invertir_lista(lista2))}")

    matriz = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    IO.puts("Suma de elementos de la matriz: #{Matrix.sum(matriz)}")

    IO.puts("Matriz transpuesta: #{inspect(Matrix.transpose(matriz))}")

    conjunto = [2, 4, 6, 8]
    objetivo = 14
    IO.puts("¿Existe combinación que sume #{objetivo}? #{existe_suma_objetivo(conjunto, objetivo)}")
  end

  # Contar elementos pares en una lista
  def elementos_pares(lista) do
    Enum.reduce(lista, 0, fn x, acc ->
      if rem(x, 2) == 0 do
        acc + 1
      else
        acc
      end
    end)
  end

  # Invertir lista sin usar Enum.reverse
  def invertir_lista(lista), do: invertir_rec(lista, [])

  defp invertir_rec([], acc), do: acc
  defp invertir_rec([h | t], acc), do: invertir_rec(t, [h | acc])

  # Ver si alguna combinación de la lista da exactamente el objetivo
  def existe_suma_objetivo(lista, objetivo) do
    combinaciones = todas_combinaciones(lista)
    Enum.any?(combinaciones, fn comb -> Enum.sum(comb) == objetivo end)
  end

  # Generar todas las combinaciones posibles de la lista
  defp todas_combinaciones(lista) do
    for n <- 1..length(lista), comb <- combinaciones(lista, n), do: comb
  end

  # Generar combinaciones (helper, función real)
  defp combinaciones(_lista, 0), do: [[]]
  defp combinaciones([], _n), do: []
  defp combinaciones([h | t], n) do
    with_h = for comb <- combinaciones(t, n - 1), do: [h | comb]
    without_h = combinaciones(t, n)
    with_h ++ without_h
  end
end

MatricesYListas.main()