let divide = require('./my-functions');
let assert = require('assert');

describe("divide function", () => {
	it("divides 1 by 1", () => {
		const result = divide(1, 1);
		assert.equal(result, 1);
	});
});

