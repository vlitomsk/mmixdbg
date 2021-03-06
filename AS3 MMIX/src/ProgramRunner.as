package  
{
	
	public class ProgramRunner 
	{
		public var memory:Array = []; // Массив для хранения битов памяти
		public var registers:Array = []; // Массив для хранения битов регистров
		public var lineNumber:int = 0; // номер исполняемой строки
		public var lastReg:int = 255; // номер наименьшего глобального регистра
		public var errorNumber:int = 0;
		public var memoryLimit:int;
		public var varMatcher:VarMatcher = new VarMatcher();
		
		public function ProgramRunner(labelArr:Array,  opArr:Array,  exprArr:Array, _memoryLimit:int) 
		{
			memoryLimit = _memoryLimit;
			var l: int = labelArr.length;
			//заведем переменные которые будем использовать в дальнейшем для различных целей
			var i:int = 0;
			var j:int = 0;
			var dummyArr:Array = [];
			var dummyLength:int;
			var isConditionPerformed:Boolean;
			var isUnsigned:Boolean; 
			var len:int; 
			//забиваем память и регистры нулями
			for (i = 0; i < 8 * memoryLimit; i++)
			{
				memory[i] = [];
				for (j = 0; j < 8; j++)
				{
					memory[i][j] = 0;
				}
			}
			for (i = 0; i < 256; i++) 
			{
				registers[i] = [];
				for (j = 0; j < 64; j++)
				{
					registers[i][j] = 0;
				}
			}
			
			for (i = 0; i < l; i++)
			{
				lineNumber = i; 
				if (opArr[i] == "GREG") 
				{
					if (exprArr[i][1] != "") 
					{
						errorNumber = 3; 
						break;
					}
					lastReg--; 
					dummyLength = exprArr[i][0].length;
					if (exprArr[i][0].charAt(0) != "#") 
					{
						registers[lastReg] = decimalToBin(exprArr[i][0]);
					}
					else
					{
						registers[lastReg] = hexToBin(exprArr[i][0].substring(1, dummyLength));
					}
					if (labelArr[i] != "") 
						varMatcher.addReg(labelArr[i], lastReg);
				}
				else if (opArr[i] == "IS")
				{
					if (exprArr[i][1] != "" || exprArr[i][0] == "") 
					{
						errorNumber = 3; 
						break;
					}
					if (labelArr[i] != "") 
						varMatcher.addVal(labelArr[i], exprArr[i][0]);
				}
				else if (opArr[i] == "ADD" || opArr[i] == "ADDU" || opArr[i] == "LDA" )
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if(opArr[i] == "ADD")
							registers[dummyArr[0]] = add(dummyArr[1], dummyArr[2], false);
						else 
							registers[dummyArr[0]] = add(dummyArr[1], dummyArr[2], true);
					}
				}
				else if (opArr[i] == "CMP" || opArr[i] == "CMPU")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if(opArr[i] == "CMP")
							registers[dummyArr[0]] = compare(dummyArr[1], dummyArr[2], false);
						else if (opArr[i] == "CMPU")
							registers[dummyArr[0]] = compare(dummyArr[1], dummyArr[2], true);
					}
				}
				else if (opArr[i] == "CSN" || opArr[i] == "ZSN")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if (dummyArr[1][0] == 1)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSN")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSZ" || opArr[i] == "ZSZ")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						isConditionPerformed = true;
						for (j = 0; j < 64; j++)
							if (dummyArr[1][j] != 0)
								isConditionPerformed = false;
						if (isConditionPerformed)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSZ")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}		
				}
				else if (opArr[i] == "CSP" || opArr[i] == "ZSP")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						isConditionPerformed = false;
						for (j = 1; j < 64; j++)
							if (dummyArr[1][j] != 0)
								isConditionPerformed = true;
						if (dummyArr[1][0] == 0 && isConditionPerformed)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSP")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSOD" || opArr[i] == "ZSOD")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if (dummyArr[1][63] == 1)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSOD")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSNN" || opArr[i] == "ZSNN")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if (dummyArr[1][0] == 0)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSNN")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSNZ" || opArr[i] == "ZSNZ")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						isConditionPerformed = false;
						for (j = 0; j < 64; j++)
							if (dummyArr[1][j] != 0)
								isConditionPerformed = true;
						if (isConditionPerformed)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSNZ")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSNP" || opArr[i] == "ZSNP")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						isConditionPerformed = true;
						for (j = 1; j < 64; j++)
							if (dummyArr[1][j] != 0)
								isConditionPerformed = false;
						if (dummyArr[1][0] == 1 || isConditionPerformed)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSNP")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "CSEV" || opArr[i] == "ZSEV")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						if (dummyArr[1][63] == 0)
							registers[dummyArr[0]] = dummyArr[2];
						else if (opArr[i] == "ZSEV")
						{
							for (j = 0; j < 64; j++)
								registers[dummyArr[0]][j] = 0;
						}
					}	
				}
				else if (opArr[i] == "STB" || opArr[i] == "STW" || opArr[i] == "STT" || opArr[i] == "STO" || 
				opArr[i] == "STBU" || opArr[i] == "STWU" || opArr[i] == "STTU" || opArr[i] == "STOU")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						//краткий способ понять что за команда использована
						isUnsigned = false;
						if (opArr[i].length == 4) 
							isUnsigned = true;
						if (opArr[i].charAt(2) == 'B') len = 1;
						if (opArr[i].charAt(2) == 'W') len = 2;
						if (opArr[i].charAt(2) == 'T') len = 4;
						if (opArr[i].charAt(2) == 'O') len = 8;
						
						dummyArr[1] = add(dummyArr[1], dummyArr[2], isUnsigned);
						dummyArr[1] = binToMemorySlot(dummyArr[1]);
						if (errorNumber == 0)
							saveToMemory(dummyArr[0], dummyArr[1], len, isUnsigned);
					}
				}
				else if (opArr[i] == "LDB" || opArr[i] == "LDW" || opArr[i] == "LDT" || opArr[i] == "LDO" || 
				opArr[i] == "LDBU" || opArr[i] == "LDWU" || opArr[i] == "LDTU" || opArr[i] == "LDOU")
				{
					dummyArr = prepareExpr(exprArr[i], 3);
					if (errorNumber == 0)
					{
						//краткий способ понять что за команда использована
						isUnsigned = false;
						if (opArr[i].length == 4) 
							isUnsigned = true;
						if (opArr[i].charAt(2) == 'B') len = 1;
						if (opArr[i].charAt(2) == 'W') len = 2;
						if (opArr[i].charAt(2) == 'T') len = 4;
						if (opArr[i].charAt(2) == 'O') len = 8;
						
						dummyArr[1] = add(dummyArr[1], dummyArr[2], isUnsigned);
						dummyArr[1] = binToMemorySlot(dummyArr[1]);
						if (errorNumber == 0)
							loadFromMemory(dummyArr[0], dummyArr[1], len, isUnsigned);
					}
				}
				if (errorNumber != 0)
					break;
			}
		}
		
		public function saveToMemory(regNum:int, index:int, len:int, unsigned:Boolean):void
		//reg - откуда пишем, index - куда, len - размер записи, unsigned - если false возможно переполнение
		{
			var newIndex:int = index / len; //индекс начиная с которого будут записываться данные
			newIndex *= len;
			if (newIndex % 8 != 0 && !unsigned)
				errorNumber = 5;
			for (var i:int = 0; i < len; i++)
				for (var j:int = 0; j < 8; j++)
					memory[newIndex + i][j] = registers[regNum][(8 - len + i) * 8 + j];
		}
		
		public function loadFromMemory(regNum:int, index:int, len:int, unsigned:Boolean):void
		{
			var newIndex:int = index / len; //индекс начиная с которого будут записываться данные
			newIndex *= len;
			var i:int;
			var j:int;
			for (i = 0; i < len; i++)
				for (j = 0; j < 8; j++)
					registers[regNum][(8 - len + i) * 8 + j] = memory[newIndex + i][j];
			for (i = 0; i < 8 - len; i++)
				for (j = 0; j < 8; j++)
				{
					if (memory[newIndex][0] == 0 || unsigned)
						registers[regNum][(8 - len - i - 1) * 8 + j] = 0;
					else
						registers[regNum][(8 - len - i - 1) * 8 + j] = 1;
				}
		}
		
		public function binToMemorySlot(bin:Array):int
		{
			var dummyInt:int = memoryLimit*8;
			var dummyCounter:int = 0;
			var res:int = 0;
			while (dummyInt > 0)
			{
				dummyCounter++;
				dummyInt /= 2;
			}
			var i:int;
			for (i = 0; i < 64 - dummyCounter; i++) //чтобы не вызывать переполнение у int
			{
				if (bin[i] == 1)
					errorNumber = 6;
			}
			if (errorNumber == 0)
			{
				for (i = 64 - dummyCounter; i < 64; i++)
					res += bin[i] * Math.pow(2, 63 - i);
				if (res >= memoryLimit*8)
					errorNumber = 6;
			}
			return res;
		}
		
		public function prepareExpr(vars:Array, n:int):Array
		//совершает общие для большинства команд действия с переданным массивом аргументов. 
		{
			var res:Array = [];
			var j:int = 0;
			for (j = 0; j < n; j++)
				if (vars[j] == "")
				{
					errorNumber = 3; 
					break;
				}
			for (j = n; j < 3; j++)
				if (vars[j] != "")
				{
					errorNumber = 3; 
					break;
				}
			res = matchVars(vars, n);
			if (errorNumber == 0)
			{
				if (!checkForReg(res[0]))
					errorNumber = 4;
				else
				{
					var l:int = res[0].length;
					res[0] = (int)(res[0].substring(1, l));
				}
				for (j = 1; j < n; j++)
				{
					l = res[j].length;
					if(checkForReg(res[j]))
						res[j] = registers[(int)(res[j].substring(1, l))];
					else if (checkForHex(res[j]))
						res[j] = hexToBin(res[j].substring(1, l));
					else 
						res[j] = decimalToBin(res[j]);
				}
			}
			return res;
		}
		
		public function matchVars(vars:Array, n:int):Array
		// принимает массив из n переменных/регистров, возвращает массив соответствующих регистров и значений
		{
			var res:Array = vars;
			for (var i:int = 0; i < n; i++)
			{
				if (!(checkForDecimal(vars[i]) || checkForHex(vars[i]) || checkForReg(vars[i]))) 
				{
					var dummy:Array = varMatcher.findVar(vars[i]);
					if (dummy[0] == -1)
						errorNumber = 4; 
					else
					{
						res[i] = dummy[dummy[0]]
						if(dummy[0] == 1)
							res[i] = "$" + dummy[1];
					}
				}
				if (!(checkForDecimal(vars[i]) || checkForHex(vars[i]) || checkForReg(vars[i])))
				{
					errorNumber = 4;
					return res;
				}
			}
			return res;
		}
		
		public function hexToBin(number:String):Array
		//Переводит 16ричное число в двоичное, представленное массивом длины 64.
		{
			var res:Array = [];
			var l:int = number.length;
			var i:int = 0;
			if (l > 16) 
			{
				errorNumber = 5;
				return res;
			}
			while (l < 16)
			{
				l++;
				number = "0" + number;
			}
			if (!checkForHex("#" + number))
			{
				errorNumber = 4;
				return res;
			}
			for (i = 0; i < 16; i++)
			{
				var decimal:int; //десятичная запись цифры из 16ричного числа
				if (number.charAt(i) == 'f') decimal = 15; 
				else if (number.charAt(i) == 'e') decimal = 14; 
				else if (number.charAt(i) == 'd') decimal = 13; 
				else if (number.charAt(i) == 'c') decimal = 12; 
				else if (number.charAt(i) == 'b') decimal = 11; 
				else if (number.charAt(i) == 'a') decimal = 10; 
				else decimal = int(number.charAt(i));
				res[i * 4] = 0;
				res[i * 4 + 1] = 0;
				res[i * 4 + 2] = 0;
				res[i * 4 + 3] = 0;
				if (decimal % 2 >= 1) res[i * 4 + 3] = 1;
				if (decimal % 4 >= 2) res[i * 4 + 2] = 1;
				if (decimal % 8 >= 4) res[i * 4 + 1] = 1;
				if (decimal % 16 >= 8) res[i * 4] = 1;
			}
			return res;
		}
		
		public function decimalToBin(number:String) : Array
		//преобразовывает 10-чное число в двоичное, представленное массивом длины 64.
		{
			var res:Array = [];
			if(!checkForDecimal(number))
			{
				errorNumber = 4;
				return res;
			}
			var l:int = number.length;
			if (number.charAt(0) == "+")
				res = hexToBin(Number(number.substring(1,l)).toString(16));
			else if (number.charAt(0) == "-")
				res = changeSign(hexToBin(Number(number.substring(1,l)).toString(16)));
			else 
				res = hexToBin(Number(number).toString(16));
			return res;
		}
		
		
		public function getErrorText(n:int):String //возвращает текст ошибки по ее номеру
		{
			if (n == 0) return "Done";
			if (n == 3) return "Wrong number of arguments at line " + (lineNumber + 1);
			if (n == 4) return "Wrong type of argument at line " + (lineNumber + 1);
			if (n == 5) return "Overflow error at line " + (lineNumber + 1);
			if (n == 6) return "Memory access error at line " + (lineNumber + 1);
			
			return "Unknown error at line " + (lineNumber + 1);
		}
		
		public function checkForReg(number:String):Boolean
		//Проверяет является ли строка символов номером регистра
		{
			var l:int = number.length;
			if (l < 2) 
				return false;
			if (number.charAt(0) != '$')
				return false
			for (var i:int = 1; i < l; i++)
			{
				if (number.charAt(i) < '0' || number.charAt(i) > '9')
				{
					return false;
				}
			}
			var dummyNum:int = int(number.substring(1, l));
			if (dummyNum < 0 || dummyNum > 255)
				return false;
			return true;
		}
		public function checkForHex(number:String):Boolean
		//Проверяет является ли строка символов 16-чным числом
		{
			var l:int = number.length;
			if (l < 2) 
				return false;
			if (number.charAt(0) != '#')
				return false
			for (var i:int = 1; i < l; i++)
			{
				if ((number.charAt(i) < '0' || number.charAt(i) > '9') && (number.charAt(i) < 'a' || number.charAt(i) > 'f'))
				{
					return false;
				}
			}
			return true;
		}
		
		public function checkForDecimal(number:String):Boolean
		//Проверяет является ли непустая строка символов 10-чным числом
		{
			if (number.charAt(0) != "+" && number.charAt(0) != "-")
				number = "+" + number;
			var l:int = number.length;
			if (l < 2)
				return false;
			for (var i:int = 1; i < l; i++)
			{
				if (number.charAt(i) < '0' || number.charAt(i) > '9')
				{
					return false;
				}
			}
			return true;
		}
		
		public function compare(Y:Array, Z:Array, unsigned:Boolean):Array
		//cравнивает двоичные числа Y, Z и возвращает в двоичной записи число 1, если Y больше; -1, если Z больше; 0, если Z = X
		{
			var X:Array = []; //результат
			var i:int = 0;
			for (i = 0; i < 63; i++)
				X[i] = 0;
			X[63] = 1;
			if (!unsigned)
			{
				if (Y[0] > Z[0])
					return changeSign(X);
				else if (Z[0] > Y[0])
					return X;
			}
			for (i = 0; i < 64; i++)
			{
				if (Y[i] > Z[i])
					return X;
				else if (Z[i] > Y[i])
					return changeSign(X);
			}
			X[63] = 0;
			return X;
		}
		
		public function add(Y:Array, Z:Array, unsigned:Boolean):Array
		{
			var X:Array = []; // результат
			var columnAdditionHelper:int = 0; 
			for (var i:int = 63; i >= 0; i--)
			{
				X[i] = (Y[i] + Z[i] + columnAdditionHelper) % 2;
				columnAdditionHelper = (Y[i] + Z[i] + columnAdditionHelper) / 2;
			}
			if (!unsigned && Y[0] == Z[0] && X[0] != Y[0]) 
				errorNumber = 5;
			return X;
		}
		
		public function substract(Y:Array, Z:Array, unsigned:Boolean):Array
		{
			var X:Array = []; // результат
			var columnSubstractionHelper:int = 0; 
			for (var i:int = 63; i >= 0; i--)
			{
				X[i] = Y[i] - Z[i] - columnSubstractionHelper;
				columnSubstractionHelper = 0;
				if (X[i] < 0)
				{
					X[i] += 2;
					columnSubstractionHelper = 1;
				}
			}
			if (!unsigned && Y[0] == 1 && X[0] == 0) 
				errorNumber = 5;
			return X;
		}
		
		public function changeSign(X:Array):Array
		{
			var dummyArr:Array = [];
			var dummyArr2:Array = [];
			for (var i:int = 0 ; i < 64; i++)
			{
				dummyArr[i] = 1;
				dummyArr2[i] = 0;
			}
			dummyArr2[63] = 1;
			return add(substract(dummyArr, X, true), dummyArr2, true);
		}
		
	}

}