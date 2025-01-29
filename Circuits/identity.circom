pragma circom 2.0.0;

template IdentityVerifier() {
    signal input id;
    signal input workExperience;
    signal output hash;

    // Example validation: ID > 1000 and workExperience >= 1 year
    signal validId <== id > 1000 ? 1 : 0;
    signal validWork <== workExperience >= 12 ? 1 : 0;
    
    // Ensure both conditions are met
    validId * validWork === 1;
    
    // Output hash of validated data
    hash <== keccak256(id, workExperience);
}

component main = IdentityVerifier();