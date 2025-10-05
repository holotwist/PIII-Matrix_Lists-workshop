defmodule Matrix do
  @moduledoc """
  A library for creating and performing operations on matrices using recursion.
  Matrices are represented as a list of lists, where each inner list is a row.
  """

  @doc """
  Creates a new matrix with the given dimensions and initial value.

  ## Examples

      iex> Matrix.new(2, 3, 0)
      [[0, 0, 0], [0, 0, 0]]
  """
  def new(rows, cols, value \\ 0) do
    new_rows(rows, cols, value)
  end

  # Helpers for new/3
  defp new_rows(0, _cols, _value), do: []
  defp new_rows(rows, cols, value) do
    [new_cols(cols, value) | new_rows(rows - 1, cols, value)]
  end

  defp new_cols(0, _value), do: []
  defp new_cols(cols, value) do
    [value | new_cols(cols - 1, value)]
  end


  @doc """
  Returns the identity matrix of a given size.

  ## Examples

      iex> Matrix.identity(3)
      [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
  """
  def identity(size) when is_integer(size) and size > 0 do
    r_identity(size, 0)
  end

  # Helpers for identity/1
  defp r_identity(size, row_idx) when row_idx < size do
    [identity_row(size, row_idx, 0) | r_identity(size, row_idx + 1)]
  end
  defp r_identity(_size, _row_idx), do: []

  defp identity_row(size, row_idx, col_idx) when col_idx < size do
    value = if row_idx == col_idx, do: 1, else: 0
    [value | identity_row(size, row_idx, col_idx + 1)]
  end
  defp identity_row(_size, _row_idx, _col_idx), do: []


  @doc """
  Calculates the sum of all numeric elements in a matrix.

  ## Examples

      iex> Matrix.sum([[1, 2], [3, 4]])
      10
  """
  def sum([]), do: 0
  def sum([head | tail]) do
    sum_row(head) + sum(tail)
  end

  # Helper for sum/1
  defp sum_row([]), do: 0
  defp sum_row([h | t]) when is_number(h), do: h + sum_row(t)
  defp sum_row([_h | t]), do: sum_row(t) # Skip non-numeric elements


  @doc """
  Sums two matrices element-wise.

  ## Examples

      iex> Matrix.sump([[1, 2], [3, 4]], [[5, 6], [7, 8]])
      [[6, 8], [10, 12]]
  """
  def sump([], []), do: []
  def sump([h1 | t1], [h2 | t2]) do
    [sump_rows(h1, h2) | sump(t1, t2)]
  end

  # Helper for sump/2
  defp sump_rows([], []), do: []
  defp sump_rows([h1 | t1], [h2 | t2]), do: [h1 + h2 | sump_rows(t1, t2)]


  @doc """
  Returns the main diagonal of a matrix.

  ## Examples

      iex> Matrix.diagonal([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      [1, 5, 9]
  """
  def diagonal(matrix) do
    r_diagonal(matrix, 0)
  end

  # Helper for diagonal/1
  defp r_diagonal([], _index), do: []
  defp r_diagonal([head | tail], index) do
    [Enum.at(head, index) | r_diagonal(tail, index + 1)]
  end


  @doc """
  Transposes a matrix.

  ## Examples

      iex> Matrix.transpose([[1, 2, 3], [4, 5, 6]])
      [[1, 4], [2, 5], [3, 6]]
  """
  def transpose([]), do: []
  def transpose([[] | _]), do: []
  def transpose(matrix) do
    heads = Enum.map(matrix, &hd/1)
    tails = Enum.map(matrix, &tl/1)
    [heads | transpose(tails)]
  end


  @doc """
  Multiplies two matrices.

  ## Examples

      iex> Matrix.mult([[1, 2], [3, 4]], [[5, 6], [7, 8]])
      [[19, 22], [43, 50]]
  """
  def mult(a, b) do
    b_t = transpose(b)
    mult_recurs(a, b_t)
  end

  # Helpers for mult/2
  defp mult_recurs([], _b_t), do: []
  defp mult_recurs([a_row | a_rest], b_t) do
    [mult_row_by_matrix(a_row, b_t) | mult_recurs(a_rest, b_t)]
  end

  defp mult_row_by_matrix(_a_row, []), do: []
  defp mult_row_by_matrix(a_row, [b_col | b_rest]) do
    [dot_product(a_row, b_col) | mult_row_by_matrix(a_row, b_rest)]
  end

  defp dot_product([], []), do: 0
  defp dot_product([h1 | t1], [h2 | t2]), do: h1 * h2 + dot_product(t1, t2)


  @doc """
  Calculates the determinant of a square matrix.
  """
  def determinant([[a]]), do: a
  def determinant([[a, b], [c, d]]), do: a * d - b * c
  def determinant(matrix) do
    {rows, cols} = size(matrix)
    if rows != cols, do: raise("Matrix must be square")
    determinant_expansion(List.first(matrix), matrix, 0)
  end

  # Helper for determinant/1
  defp determinant_expansion([], _matrix, _col_index), do: 0
  defp determinant_expansion([h | t], matrix, col_index) do
    sign = if rem(col_index, 2) == 0, do: 1, else: -1
    term = h * sign * determinant(minor(matrix, 0, col_index))
    term + determinant_expansion(t, matrix, col_index + 1)
  end


  @doc """
  Calculates the inverse of a square matrix.
  """
  def inverse(matrix) do
    det = determinant(matrix)
    if det == 0, do: raise("Matrix is not invertible")

    adj_matrix = adj(matrix)
    divide_matrix(adj_matrix, det)
  end

  # Helper for inverse/1
  defp divide_matrix([], _det), do: []
  defp divide_matrix([h | t], det) do
    [divide_row(h, det) | divide_matrix(t, det)]
  end

  defp divide_row([], _det), do: []
  defp divide_row([h | t], det), do: [h / det | divide_row(t, det)]


  @doc """
  Calculates the adjugate (or classical adjoint) of a square matrix.
  """
  def adj(matrix) do
    {rows, _} = size(matrix)
    cofactor_matrix = build_cofactor_matrix(matrix, rows, 0)
    transpose(cofactor_matrix)
  end

  # Helpers for adj/1
  defp build_cofactor_matrix(_matrix, rows, row_idx) when row_idx >= rows, do: []
  defp build_cofactor_matrix(matrix, rows, row_idx) do
    {_, cols} = size(matrix)
    new_row = build_cofactor_row(matrix, row_idx, cols, 0)
    [new_row | build_cofactor_matrix(matrix, rows, row_idx + 1)]
  end

  defp build_cofactor_row(_matrix, _row_idx, cols, col_idx) when col_idx >= cols, do: []
  defp build_cofactor_row(matrix, row_idx, cols, col_idx) do
    cof = cofactor(matrix, row_idx, col_idx)
    [cof | build_cofactor_row(matrix, row_idx, cols, col_idx + 1)]
  end


  # --- Private Helper Functions ---

  @doc """
  Returns the size of a matrix as {rows, columns}.
  """
  def size([]), do: {0, 0}
  def size([h | _] = matrix) do
    {Enum.count(matrix), Enum.count(h)}
  end

  @doc """
  Calculates the minor of an element.
  """
  defp minor(matrix, row_index, col_index) do
    matrix_without_row = remove_at(matrix, row_index)
    remove_col(matrix_without_row, col_index)
  end

  # Replaces List.delete_at for the outer list
  defp remove_at(list, index) do
    {leading, [_ | trailing]} = Enum.split(list, index)
    leading ++ trailing
  end

  defp remove_col([], _col_index), do: []
  defp remove_col([head | tail], col_index) do
    [remove_at(head, col_index) | remove_col(tail, col_index)]
  end

  @doc """
  Calculates the cofactor of an element.
  """
  defp cofactor(matrix, row_index, col_index) do
    sign = if rem(row_index + col_index, 2) == 0, do: 1, else: -1
    sign * determinant(minor(matrix, row_index, col_index))
  end
end