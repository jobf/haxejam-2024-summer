package lib.pure;

@:structInit
class Point
{
	public var column: Int;
	public var row: Int;
}

enum CardinalDirection
{
	NONE;
	NORTH;
	EAST;
	SOUTH;
	WEST;
}

class GridLogic
{
	public var numColumns(default, null): Int;
	public var numRows(default, null): Int;

	public function new(numColumns: Int, numRows: Int)
	{
		this.numColumns = numColumns;
		this.numRows = numRows;
	}

	public function isInBounds(column: Int, row: Int): Bool
	{
		return column >= 0 && row >= 0 && column < numColumns && row < numRows;
	}

	public function column(index: Int): Int
	{
		return Std.int(index % numColumns);
	}

	public function row(index: Int): Int
	{
		return Std.int(index / numColumns);
	}

	public function index(column: Int, row: Int): Int
	{
		return column + numColumns * row;
	}
}

class GridStructure<T> extends GridLogic
{
	public var cells(default, null): Array<T>;

	var cellInit: (column: Int, row: Int) -> T;

	public function new(numColumns: Int, numRows: Int, cellInit: (column: Int, row: Int) -> T)
	{
		super(numColumns, numRows);
		this.cellInit = cellInit;
		init();
	}

	function init()
	{
		cells = [];
		for (i in 0...(this.numColumns * this.numRows))
		{
			var x = column(i);
			var y = row(i);
			cells.push(cellInit(x, y));
		}
	}

	public function forEach(processCell: (column: Int, row: Int, T) -> Void, isReversed: Bool = false)
	{
		if (isReversed)
		{
			var i = cells.length;
			while (i-- > 0)
			{
				processCell(column(i), row(i), cells[i]);
			}
		}
		else
		{
			for (i => cell in cells)
			{
				processCell(column(i), row(i), cell);
			}
		}
	}

	public function forEachCanExitEarly(processCell: (column: Int, row: Int, T) -> Bool, isReversed: Bool = false)
	{
		var shouldExitEarly = false;
		if (isReversed)
		{
			var i = cells.length;
			while (i-- > 0)
			{
				shouldExitEarly = processCell(column(i), row(i), cells[i]);
				if (shouldExitEarly)
					break;
			}
		}
		else
		{
			for (i => cell in cells)
			{
				shouldExitEarly = processCell(column(i), row(i), cell);
				if (shouldExitEarly)
					break;
			}
		}
	}

	public function indexesInSection(x: Int, y: Int, w: Int, h: Int): Array<Int>
	{
		var temp = new GridLogic(w, h);
		var total = w * h;
		return [
			for (i in 0...total)
			{
				var c = temp.column(i) + x;
				var r = temp.row(i) + y;
				index(c, r);
			}
		];
	}

	public function forEachInSection(x: Int, y: Int, w: Int, h: Int, processCell: (Int, T) -> Void)
	{
		var rowIndexMax = w - 1;
		var minIndex = index(x, y);
		var maxIndex = index(x + rowIndexMax, y + h) - 1;
		var i = minIndex;
		var iInRow = 0;
		var indexSkip = numColumns - w;
		while (i < maxIndex)
		{
			processCell(i, cells[i]);
			i++;
			iInRow++;
			if (iInRow > rowIndexMax)
			{
				iInRow = 0;
				i += indexSkip;
			}
		}
	}

	public function forSingleCoOrdinate(column: Int, row: Int, processCell: (column: Int, row: Int, T) -> Void)
	{
		processCell(
			column,
			row,
			cells[index(column, row)]
		);
	}

	public function forSingleIndex(index: Int, processCell: (column: Int, row: Int, T) -> Void)
	{
		processCell(column(index), row(index), cells[index]);
	}

	public function get(column: Int, row: Int): Null<T>
	{
		return isInBounds(column, row) ? cells[index(column, row)] : null;
	}

	/**
		store the passed cell into the grid at column,row
	**/
	public function set(column: Int, row: Int, cell: T)
	{
		cells[index(column, row)] = cell;
	}

	/**
		update cell at column,row by modifying with the function passed
	**/
	public function update(column: Int, row: Int, modifier: T -> Void)
	{
		modifier(cells[index(column, row)]);
	}

	public function swap(indexA: Int, indexB: Int)
	{
		var A = cells[indexA];
		var B = cells[indexB];
		var a = A;
		cells[indexA] = B;
		cells[indexB] = a;
	}

	public function toString(formatCell: T -> String = null): String
	{
		var buffer: String = "\n";
		for (r in 0...numRows)
		{
			var start = r * numColumns;
			var end = start + numColumns;
			var row = cells.slice(start, end);
			if (formatCell == null)
			{
				formatCell = formatString;
			}
			var line = [for (c in row) formatCell(c)].join("");
			buffer += line += "\n";
		}
		return buffer;
	}

	public function formatString(c: T): String
	{
		return '$c';
	}

	public function resize(numColumns: Int, numRows: Int)
	{
		this.numColumns = numColumns;
		this.numRows = numRows;
		init();
	}
}

class GridView<T>
{
	var x: Int;
	var y: Int;
	var w: Int;
	var h: Int;
	var indexesInView: Array<Int>;
	var grid: GridStructure<T>;

	public var view(default, null): GridStructure<T>;

	public var cellsInView(default, null): Array<T>;

	public function new(x: Int, y: Int, w: Int, h: Int, grid: GridStructure<T>)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.grid = grid;

		init();
	}

	function init()
	{
		view = new GridStructure<T>(w, h, (x, y) ->
		{
			grid.get(x, y);
		});
		cellsInView = grid.cells.slice(0, w * h);
		indexesInView = grid.indexesInSection(x, y, w, h);
		updateView();
	}

	public function updateView()
	{
		for (i => viewedIndex in indexesInView)
		{
			cellsInView[i] = grid.cells[viewedIndex];
			view.cells[i] = grid.cells[viewedIndex];
		}
	}
}
