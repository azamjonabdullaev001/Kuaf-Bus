const bcrypt = require('bcryptjs');

const password = 'K7mP9nQ2rS5tV8xW1yZ4aB6cD3eF';
const salt = bcrypt.genSaltSync(10);
const hash = bcrypt.hashSync(password, salt);

console.log('Password:', password);
console.log('Hash:', hash);
console.log('\nSQL для init-db.sql:');
console.log(`'${hash}'`);

// Verify
const isValid = bcrypt.compareSync(password, hash);
console.log('\nVerification:', isValid ? 'SUCCESS' : 'FAILED');
