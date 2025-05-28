contract HaiLinHanSC {
	event Added(string product_info);

	function Add(string memory product_info) public {
		emit Added(product_info);
	}
}
