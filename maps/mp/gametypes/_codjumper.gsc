// Correct issue with maps that reference old CJ Functions.

loadPos()
{
	self thread [[level._cj_load]](1);
}

savePos()
{
	self thread [[level._cj_save]](1);
}