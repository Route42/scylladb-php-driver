<?php
declare(strict_types=1);


namespace Cassandra\Tests\Unit\Uuid;
use Cassandra\Exception\InvalidArgumentException;
use Cassandra\Uuid;

$badUuid = 'not-an-uuid-btw';
uses()->group('unit');

test('can generate unique uuids', function () {
    foreach (range(0, 10000) as $i) {
        expect(new Uuid())->not()->toBe(new Uuid());
    }
});

test('can validate equals uuids', function () {
    $uuid1 = new Uuid('2a5072fa-7da4-4ccd-a9b4-f017a3872304');
    $uuid2 = new Uuid('2a5072fa-7da4-4ccd-a9b4-f017a3872304');

    expect($uuid1)->toEqual($uuid2)
        ->and($uuid1 == $uuid2)->toBeTrue();
});

test('can validate unequals uuids', function () {
    $uuid1 = new Uuid('2a5072fa-7da4-4ccd-a9b4-f017a3872304');
    $uuid2 = new Uuid('3b5072fa-7da4-4ccd-a9b4-f017a3872304');

    expect($uuid1)->not()->toEqual($uuid2)
        ->and($uuid1 == $uuid2)->toBeFalse();
});

test('will throw an error when input a bad uuid', function () use ($badUuid) {
    new Uuid($badUuid);
})->throws(InvalidArgumentException::class, sprintf('Invalid UUID: \'%s\'', $badUuid));