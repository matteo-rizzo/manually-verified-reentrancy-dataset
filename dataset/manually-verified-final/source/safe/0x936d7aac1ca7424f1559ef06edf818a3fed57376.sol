contract Diploma {

    bytes16 ipft_hash = 0x845e9f56005bc7a0240113314ccf257a;

    function validate(bytes16 num) public view returns (bool){
        if (num == ipft_hash) {
            return true;
        }
        else {
            return false;
        }
    }

}
