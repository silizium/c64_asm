// renumber BASIC in provided memory slice (0..max)
// processes GOTO, GOSUB, GO TO, ON GOTO|GOSUB|GO TO, THEN

function renumberBasic(mem, basicStart, startNo, step) {

   var lineNoTable = {},
       lines = [],
       maxLineNo = 36999;

   // parse and split lines to chunks of blobs and line targets
   // stores parsed chunks in array lines,
   // generates a reference of old and new line numbers in lineNoTable.
	function parseSplit() {

		var addr = basicStart,
			lineNo = startNo,
			maxMem = mem.length,
			chunks,
			blob;

		while (addr < maxMem) {
		   var lineLink = mem[addr++] + (mem[addr++]<<8);
		   if (!lineLink) break;
		   chunks = [];
		   blob = [];
		   var ln = String(mem[addr++] + (mem[addr++]<<8)),
			   byte = mem[addr++],
			   line = {
				  'ln': ln,
				  'chunks': chunks
			   };
		   lineNoTable[ln] = lineNo;
		   lineNo += step;
		   while (byte) {
			  blob.push(byte);
			  switch(byte) {
				 case 0x8F: // REM (read rest of line)
					while (mem[addr]) blob.push(mem[addr++]);
					break;
				 case 0x22: // quote (read up to next quote)
					var c = mem[addr++];
					while (c) {
					   blob.push(c);
					   if (c === 0x22) break;
					   c = mem[addr++];
					}
					break;
				 case 0x89: // GOTO
				 case 0x8D: // GOSUB
					parseLineTarget(true);
					break;
				 case 0xA7: // THEN
					parseLineTarget(false);
					break;
				 case 0xCB: // GO (read ahead and test for TO)
					var t = addr;
					while (mem[t] == 0x20) t++; // skip any blanks
					if (mem[t] !== 0xA4) break;
					while (addr <= t) blob.push(mem[addr++]);
					parseLineTarget(true);
					break;
			  }
			  byte = mem[addr++];
		   }
		   if (blob.length) chunks.push({'type': 'blob', 'val': blob});
		   lines.push(line);
		   addr = lineLink;
	   }
	}

   // reassamble BASIC code from line chunks using new line numbers
   // from lineNoTable
	function reassembleLines() {
	   var addr = basicStart;
	   for (var i = 0, max = lines.length; i < max; i++) {
		  var currLine = lines[i],
			  currNo = lineNoTable[currLine.ln],
			  linkAddr = addr;
		  mem[addr++] = 0;
		  mem[addr++] = 0;
		  mem[addr++] = currNo & 0xFF;
		  mem[addr++] = (currNo >> 8) & 0xFF;
		  // transfer chunks to memory
		  for (var j = 0; j < currLine.chunks.length; j++) {
			 var chunk = currLine.chunks[j];
			 if (chunk.type === 'blob') {
				var blob = chunk.val;
				for (var k = 0; k < blob.length; k++)
				   mem[addr++] = blob[k];
			 }
			 else if (chunk.type === 'target') {
				var s = '';
				if (chunk.val) {
				   var n = lineNoTable[chunk.val];
				   s = typeof n !== 'undefined'? n.toString(10):chunk.val;
				}
				for (var k = 0; k < s.length; k++)
				   mem[addr++] = s.charCodeAt(k);
			 }
		  }
		  mem[addr++] = 0; //EOL
		  // fix up the line link
		  mem[linkAddr++] = addr & 0xFF;
		  mem[linkAddr] = (addr >> 8) & 0xFF;
	   }


   parseSplit();
   // check, if we are still in the range of legal line numbers
   if (lines.length) {
      var topLineNo = lineNoTable[lines[lines.length - 1].ln];
      // we could throw an exception as well…
      if (topLineNo > maxLineNo) return {
         'addr': -1,
         'message': 'Out of range. Top line number is ' + topLineNo +
                    ' (' + maxLineNo + ' allowed).'
      };
   }
   var endAddr = reassembleLines();
   return {
      'addr': endAddr
   };

	   // end of code (empty line link)
	   mem[addr++] = 0;
	   mem[addr++] = 0;
	   return addr;
	}


   parseSplit();
   reassembleLines();

}

// scans for a jump target,
    // generates a target entry and a new blob in current chunks,
    // any leading blanks are added to the current blob
    function parseLineTarget(maybeList) {
       while (mem[addr] === 0x20) {
          blob.push(0x20);
          addr++;
       }
       // parse ASCII to string, ignoring any blanks
       var n = '',
           c = mem[addr];
       while ((c >= 0x30 && c <= 0x39) || c === 0x20) {
          if (c !== 0x20) n += String.fromCharCode(c);
          c = mem[++addr];
       }
       // if we found a number, push chunks and open a new blob
       if (n !== '') {
          chunks.push({'type': 'blob', 'val': blob});
          chunks.push({'type': 'target', 'val': n});
          blob = [];
          // scan for any comma (ON GOTO|GOSUB|GO TO)
          if (maybeList && c === 0x2C) {
             blob.push(0x2C);
             addr++;
             parseLineTarget(true);
          }
       }
    }


