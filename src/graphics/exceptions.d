module graphics.exceptions;

import graphics;

class GraphicsException : Exception
{
	int code;

	this(string msg = null, string file = __FILE__, size_t line = __LINE__)
	{
		if (msg == null) {
			super(error_description, file, line);
			this.code = error_code;
			error_code = 0;
			error_description = null;
		} else {
			super(msg, file, line);
			this.code = 0;
		}
	}
}


class CorruptFileException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}
